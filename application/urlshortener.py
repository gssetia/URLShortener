import redis
from cassandra.cluster import Cluster
from flask import Flask, request, redirect, abort
import logging

logging.basicConfig(filename='log/shortener.log',level=logging.DEBUG, format=f'%(asctime)s %(levelname)s %(name)s %(threadName)s : %(message)s')

cluster = Cluster(['10.11.1.27', '10.11.2.27'])
session = cluster.connect('cassandraurlshortner')
cache = redis.Redis(host='redis', port=6379, db=0)

app = Flask(__name__)

get_query="SELECT long FROM urls WHERE short=%s"
put_query="UPDATE urls SET long=%s WHERE short=%s"

@app.route('/<short>', methods=['GET'])
def handle_get(short):
	query = cache.get(short)
	app.logger.info("GET: {}".format(query))
	if query:
		app.logger.info("Redis success, long: {}".format(query.decode()))
		return redirect(query.decode(), code=307)
	output = session.execute(get_query, [short])
	if output:
		app.logger.info("Cassandra success, long: {}".format(output[0].long))
		cache.set(short, output[0].long)
		return redirect(output[0].long, code=307)
	app.logger.error("ERROR 404 - PAGE NOT FOUND - No cooresponding long exists")
	return "ERROR 404 - PAGE NOT FOUND - No such short exists\n"

@app.route('/', methods=['PUT'])
def handle_put():
	longString = request.args.get('long')
	shortString = request.args.get('short')
	if len(request.args) != 2 or not longString or not shortString:
		app.logger.error('ERROR 400 - BAD REQUEST')
		abort(400)
	app.logger.info("PUT: {} -> {}".format(shortString, longString))	
	query = cache.get(shortString)
	if query:
		cache.set(shortString, longString)
	app.logger.info("200 - Success, put added. \n")
	session.execute(put_query, [shortString, longString])
	return "200 - Success, put added. \n"
		

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True)
