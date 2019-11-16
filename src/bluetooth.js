import prop from 'ramda/src/prop';
import invoker from 'ramda/src/invoker';
import compose from 'ramda/src/compose';

//--- getEventValue :: Event -> a
const getEventValue = compose(
  prop('value'),
  prop('target')
)

//---  getFirstByteOffset :: DataView -> Number
const getFirstByteOffset = invoker(1, 'getUint8')

//--- getHeartBeatValue :: Event -> Number
const getHeartBeatValue = compose(
  getFirstByteOffset(1),
  getEventValue
)

const requestBluetooth = (dispatch) =>
  navigator.bluetooth.requestDevice({ filters: [{ services: ['heart_rate'] }] })
    .then(device => {
      return device.gatt.connect();
    })
    .then(server => {
      return server.getPrimaryService('heart_rate')
    })
    .then(service => {
      return service.getCharacteristic('heart_rate_measurement')
    })
    .then(characteristic => characteristic.startNotifications())
    .then(characteristic => {
      characteristic.addEventListener('characteristicvaluechanged', (e) => {
        console.log(getHeartBeat(e))
      })
    })
    .catch(console.error)


export default requestBluetooth
