import './styles.css'
import { Elm } from './Main.elm'
import requestBluetooth from './bluetooth'

document.addEventListener('DOMContentLoaded', () => {
  const metroElement = document.querySelector('audio')

  const app = Elm.Main.init({
    flags: {
      hasBluetooth: 'bluetooth' in navigator
    },
    node: document.querySelector('.root')
  })

  app.ports.requestBT.subscribe(function () {
    requestBluetooth(app.ports.receiveHeartBeat.send);
  })

  app.ports.metronome.subscribe(function () {

    metroElement.pause()
    metroElement.currentTime = 0;
    metroElement.play()
  })
})
