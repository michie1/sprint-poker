import('./src/App.elm').then(Elm => {
    const mountNode = document.getElementById('app');
    const app = Elm.App.embed(mountNode);
});
