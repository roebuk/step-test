import './styles.css'
import { Elm } from './Main.elm'

const app = Elm.Main.init({
  flags: {
    hasBluetooth: 'bluetooth' in navigator
  },
  node: document.querySelector('.root')
})
