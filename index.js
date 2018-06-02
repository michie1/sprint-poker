import('./src/Main.elm').then(Elm => {
  const mountNode = document.getElementById('app');
  const app = Elm.Main.embed(mountNode);
  const config = require('./config');

  app.ports.infoForOutside.subscribe(function (msg) {
    console.log('msg', msg);
  });


  firebase.initializeApp(config);
   firebase.auth().onAuthStateChanged(function(user) {
    console.log('user', user);
    if (user !== null) {

      app.ports.infoForElm.send({
        tag: 'signedIn',
        data: user.uid
      });

      var listRef = firebase.database().ref('/presence/');
      var userRef = listRef.push();
      userRef.set({
        uid: user.uid,
        name: user.uid,
        score: null
      });

      // Add ourselves to presence list when online.
      var presenceRef = firebase.database().ref('/.info/connected');
      presenceRef.on("value", function(snap) {
        if (snap.val()) {
          // Remove ourselves when we disconnect.
          userRef.onDisconnect().remove();
        }
      });

      // Number of online users is the number of objects in the presence list.
      listRef.on("value", function(snap) {
        console.log("# of online users = " + snap.numChildren());
        console.log(snap.val());

        app.ports.infoForElm.send({
          tag: 'users',
          data: Object.values(snap.val())
        });
      });
    } else {
      firebase.auth().signInAnonymously();
    }
  });
});
