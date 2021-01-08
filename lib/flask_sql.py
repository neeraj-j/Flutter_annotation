
# This file contains flask routines to serve flutter_annotate

from flask import Flask, jsonify, request
from flask_cors import CORS, cross_origin
from glob import glob
from PIL import Image as PI
import json
import io, os, sys
import base64
import time
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.sql import func


app = Flask(__name__)
# Flask RESTful cross-domain issue with Angular: PUT, OPTIONS methods
cors = CORS(app, resources={r"/api/*": {"origins": "*"}})
# sqlalchemy
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://pi:pi@192.168.1.3/slpp'
db = SQLAlchemy(app)

# yoga files
cocoFilePath = "../yogadata/annotations/slpp_annot_kp_60_{}.json"
imgPath ="../yogadata/slpp_images/"

wrkr1_videos = list(range(1, 5)) 
wrkr2_videos = list(range(10, 20)) 
wrkr3_videos = list(range(30, 40)) 
worker = {"1":wrkr1_videos,
        "2":wrkr2_videos}

class Image(db.Model):
    __tablename__ = 'images'

    id = db.Column(db.Integer, primary_key=True)
    filename = db.Column(db.String(50))
    filepath = db.Column(db.String(150))
    video_id = db.Column(db.Integer)
    height = db.Column(db.Integer)
    width = db.Column(db.Integer)
    worker_id = db.Column(db.Integer)
    modified = db.Column(db.Integer, default=0)
    modify_dtime = db.Column(db.DateTime(timezone=False))
    verify_dtime = db.Column(db.DateTime(timezone=False))

    def __repr__(self):
       return "<Image(filename='%s', filepath='%s', height='%d', width='%d', worker Id='%d')>" % (
                            self.filename, self.filepath, 
                            self.height, self.width, self.worker_id)


class Annotation(db.Model):
    __tablename__ = 'annotations'

    id = db.Column(db.Integer, primary_key=True)
    segmentation = db.Column(db.ARRAY(db.Integer))
    keypoints = db.Column(db.ARRAY(db.Integer))
    bbox = db.Column(db.ARRAY(db.Integer))
    num_keypoints = db.Column(db.Integer)
    iscrowd = db.Column(db.Boolean, default=False)
    category_id = db.Column(db.Integer, default=1)
    image_id = db.Column(db.Integer, db.ForeignKey('images.id'))
    images = db.relationship("Image", back_populates="annotations")

    def __repr__(self):
        return "<Image(segmentation='%s', keypoints='%s', bbox='%s',  \
                        num_keypoints='%d', iscrowd='%s', category_id='%d',\
                        image_id='%d')>" % (
            json.dumps(self.segmentation),
            json.dumps(self.keypoints),
            json.dumps(self.bbox), self.num_keypoints, int(self.iscrowd),
            self.category_id, self.image_id)

Image.annotations = db.relationship(
         "Annotation", order_by=Annotation.id, 
         back_populates="images",
         cascade="all, delete",  # delete whne parent is deleted
         passive_deletes=True)

db.create_all()


# send coco file
@app.route("/coco/<cocoidx>", methods=['GET'])
def getCoco(cocoidx):
    if int(cocoidx) <0 or int(cocoidx) >6:
      print("Error: Wrong Password {}".format(cocoidx))
      return jsonify(success=True) 

    sufix = str(cocoidx)+"_*"
    filepath = cocoFilePath.format(sufix)
    filelist = sorted(glob(filepath))
    print(filelist[-1])
    # read last file
    with open(filelist[-1]) as f:
        data = f.read()
    return data

# save coco file
@app.route("/cocosave/<workerid>", methods=['PUT'])
def putCoco(workerid):
    if int(workerid) <0 or int(workerid) >6:
        print("Error: Wrong Password {}".format(cocoidx))
        return jsonify(success=False) 
    print("Saving coco " +time.strftime("%H:%M:%S", time.localtime()) , file = sys.stderr)
    annots = json.loads(request.data)
    #print(annots)
    for annot in annots:
        annRec = Annotation.query.filter_by(id=annot['id']).first()
        annRec.images.worker_id=int(workerid)
        #print(annRec.images)
        annRec.images.modify_dtime= func.now()  # time stamp
        if len(annot['bbox'])==0:
          annRec.images.modified= 1 #no change
          #print("Not changed")
        else:
          annRec.images.modified= 2 #changed
          #print("changed")
          annRec.bbox = annot['bbox']
          annRec.keypoints = annot['keypoints']
        db.session.commit()
    return jsonify(success=True) 


# sort in name
def dicfunc(e):
    return e['name']

# send images and annotation based on worker
@app.route("/datalist/<workr_id>", methods=['GET'])
def send_image_list(workr_id):
    print("Sending list " +time.strftime("%H:%M:%S", time.localtime()) , file = sys.stderr)
    qryList = Image.query.filter(Image.video_id.in_(worker[workr_id])).order_by(Image.id)
    imgList = []
    for imgRec in qryList:
        fdata ={}
        fdata['name'] = imgRec.filename 
        fdata["width"] = imgRec.width  # to be filled while sending image
        fdata["height"] = imgRec.height
        anns=[]
        for annot in imgRec.annotations:
            ann = {}
            ann["keypoints"] = annot.keypoints
            ann["bbox"] = annot.bbox
            ann["id"] = annot.id
            anns.append(ann)

        fdata['annotations'] = anns
        imgList.append(fdata)

    #imgList.sort(key=dicfunc)
    return jsonify(imgList)

@app.route("/images/<name>", methods=['GET'])
def send_image(name):
  imdata = {}
  img = PI.open(imgPath + name)  
  rawBytes = io.BytesIO()
  img.save(rawBytes, "JPEG")
  rawBytes.seek(0)
  img_base64 = base64.b64encode(rawBytes.read())
  imdata['image'] = img_base64
  return jsonify(imdata)


# delete image
@app.route("/delete/<name>", methods=['DELETE'])
def deleteImg(name):
    print("log: Deleting image {}".format(name) , file = sys.stderr)
    imgRec = Image.query.filter_by(filename=name).first()
    db.session.delete(imgRec)
    db.session.commit()
    return jsonify(success=True) 

# for debugging incoming request
'''
@app.before_request
def before_request():
    print (request.__dict__)
    return 
'''


@app.after_request
def after_request(response):
    #print("log: setting cors" , file = sys.stderr)
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.set('Content-Type', 'application/json; charset=utf-8')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

if __name__ == '__main__':
    app.debug=True
    app.run(host='0.0.0.0',port=9000)

