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
        dispatch(getHeartBeat(e))
      })
    })
    .catch(() => dispatch(userCancelled()))


export default requestBluetooth
