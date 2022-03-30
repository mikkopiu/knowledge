const zlib = require('zlib')

// Example:
// node create-test-event.js '{ "message": "Order updated" }'

const input = process.argv[2]
if (!input) {
  throw Error('Give input as first argument')
}

const cwEvent = {
  messageType: 'DATA_MESSAGE',
  owner: '123456789123',
  logGroup: 'testLogGroup',
  logStream: 'testLogStream',
  subscriptionFilters: ['testFilter'],
  logEvents: [{ timestamp: 0, message: input }]
}
const json = JSON.stringify(cwEvent)
const payload = zlib.gzipSync(json)
const encoded = Buffer.from(payload, 'utf8').toString('base64')
console.log(JSON.stringify({
  awslogs: {
    data: encoded
  }
}))
