const express    = require('express');
const bodyParser = require('body-parser');

const app = express();


app.use(bodyParser.urlencoded({ extended: false, limit: '100mb' }));
//app.use(bodyParser.z);

let lastRequest = null;

//The request body should be a ZLIB compressed JSON object
app.post('/record', (req, res) => {
	for (prop in req.body) {
		lastRequest = JSON.parse(prop);
		break;
	}
	res.send('OK');
});

app.get('/view', (req, res) => {
	res.send(lastRequest);
});

app.listen(3000);
console.log("listening..");
