const path = require('path')

exports.handler = (evt, ctx, cb) => {
    const {request} = evt.Records[0].cf
    if (!path.extname(request.uri)) {

        var uri = '/home/index.html'

        var base_dir = request.uri.split('/')[1]
        if (base_dir != "") {
            uri = '/' + base_dir + '/index.html'
        }
        request.uri = uri
    }
    console.log(evt.Records[0].cf)
    cb(null, request)
}