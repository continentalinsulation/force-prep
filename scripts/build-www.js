// Copies the web app into www/ for Capacitor. The web app itself is served from GitHub Pages; the native shell bundles the same files.
const fs=require('fs'), path=require('path');
const root=path.join(__dirname,'..'); const out=path.join(root,'www');
fs.rmSync(out,{recursive:true,force:true}); fs.mkdirSync(out);
for(const f of ['index.html','app.js','exercises.js','manifest.json','sw.js','privacy.html','support.html','icon-192.png','icon-512.png','icon-maskable-512.png','apple-touch-icon.png']){ fs.copyFileSync(path.join(root,f),path.join(out,f)); }
console.log('www/ built');
