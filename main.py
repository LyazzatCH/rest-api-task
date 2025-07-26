from google.cloud import firestore
import uuid
from flask import jsonify

db = firestore.Client()
collection = db.collection('items')

def hello_http(request):
    if request.method == 'POST':
        data = request.get_json(silent=True)
        if not data:
            return jsonify({'error': 'Invalid JSON'}), 400
        item_id = str(uuid.uuid4())
        data['id'] = item_id
        collection.document(item_id).set(data)
        return jsonify({'message': 'Data saved', 'data': data}), 200

    elif request.method == 'GET':
        item_id = request.args.get('id')
        if item_id:
            doc = collection.document(item_id).get()
            if doc.exists:
                return jsonify(doc.to_dict()), 200
            else:
                return jsonify({'error': 'Item not found'}), 404
        else:
            docs = collection.stream()
            all_items = [doc.to_dict() for doc in docs]
            return jsonify(all_items), 200
