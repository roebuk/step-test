import './styles.css'
import { Elm } from './Main.elm'
import requestBluetooth from './bluetooth'

const app = Elm.Main.init({
  flags: {
    hasBluetooth: 'bluetooth' in navigator
  },
  node: document.querySelector('.root')
})

app.ports.requestBT.subscribe(function () {
  requestBluetooth();
})
