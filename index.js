import('./src/Main.elm').then(({ Elm }) => {
  const mountNode = document.getElementById('app');
  const app = Elm.Main.init({
    node: document.getElementById('app'),
  });
  const config = require('./config');


  firebase.initializeApp(config);
   firebase.auth().onAuthStateChanged(function(user) {
    if (user !== null) {

      app.ports.infoForElm.send({
        tag: 'SignedIn',
        data: user.uid
      });

      var listRef = firebase.database().ref('/presence/');
      var userRef = listRef.push();
      userRef.set({
        uid: user.uid,
        name: user.uid,
        points: null
      });

      // Add ourselves to presence list when online.
      var presenceRef = firebase.database().ref('/.info/connected');
      presenceRef.on("value", function(snap) {
        if (snap.val()) {
          // Remove ourselves when we disconnect.
          userRef.onDisconnect().remove();
        }
      });

      listRef.on("value", function(snap) {
        app.ports.infoForElm.send({
          tag: 'UsersLoaded',
          data: Object.values(snap.val() || {})
        });
      });


      listRef.on('child_removed', function(removedUser) {
        if (removedUser.val().uid === user.uid) {
          userRef.remove();
          app.ports.infoForElm.send({
            tag: 'UserRemoved',
            data: true
          });
        }
      });

      app.ports.infoForOutside.subscribe(function (msg) {
        if (msg.tag === 'SetName') {
          userRef.update({
            name: msg.data
          });
        } else if (msg.tag === 'SetPoints') {
          userRef.update({
            points: msg.data
          });
        } else if (msg.tag === 'Reset') {
          const updates = {};
          listRef.once('value', (users) => {
            users.forEach((user) => {
              updates[user.key + '/points'] = null;
            });
          });
          listRef.update(updates);
        } else if (msg.tag === 'RemoveUser') {
          listRef.once('value', (users) => {
            users.forEach((user) => {
              if (user.val().uid === msg.data) {
                user.getRef().remove();
              }
            });
          });
        }
      });
    } else {
      firebase.auth().signInAnonymously();
    }
  });
});
