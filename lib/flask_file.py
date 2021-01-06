# This file contains flask routines to serve flutter_annotate

from flask import Flask, jsonify, request
from flask_cors import CORS, cross_origin
from glob import glob
from PIL import Image
import io, os, sys
import base64
import time

app = Flask(__name__)
# Flask RESTful cross-domain issue with Angular: PUT, OPTIONS methods
cors = CORS(app, resources={r"/api/*": {"origins": "*"}})
# coco files
#cocoFilePath = "../coco/annotations/person_keypoints_val2017_2.json"
#imgPath = "../coco/images/val2017/" 
# yoga files
cocoFilePath = "../yogadata/annotations/slpp_annot_kp_60_{}.json"
imgPath ="../yogadata/slpp_images/"
imgspfile = 3959

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
@app.route("/cocosave/<cocoidx>", methods=['PUT'])
def putCoco(cocoidx):
    if int(cocoidx) <0 or int(cocoidx) >6:
        print("Error: Wrong Password {}".format(cocoidx))
        return jsonify(success=False) 
    print("Saving coco " +time.strftime("%H:%M:%S", time.localtime()) , file = sys.stderr)
    #print(cocoData, file=sys.stderr)
    sufix = str(cocoidx)+"_*"
    filepath = cocoFilePath.format(sufix)
    filelist = sorted(glob(filepath))
    # delete oldtst file
    if len(filelist) >3:
        os.remove(filelist[0])
    # write new file
    sufix = str(cocoidx)+"_"+str(int(time.time()))
    with open(cocoFilePath.format(sufix),"wb") as f:
        f.write(request.data)
    return jsonify(success=True) 


# sort in name
def dicfunc(e):
    return e['name']

# This function is not used anymore
@app.route("/images", methods=['GET'])
def send_image_list():
    imgList = []
    for fname in glob(imgPath+"*.jpg"):
        fdata ={}
        fdata['name'] = os.path.basename(fname)
        fdata["width"] = 0  # to be filled while sending image
        fdata["height"] = 0
        imgList.append(fdata)

    imgList.sort(key=dicfunc)
    return jsonify(imgList[cocoidx*imgspfile:(cocoidx+1)*imgspfile])
    #return jsonify(imgList)

@app.route("/images/<name>", methods=['GET'])
def send_image(name):
  imdata = {}
  img = Image.open(imgPath + name)  
  w, h = img.size
  rawBytes = io.BytesIO()
  img.save(rawBytes, "JPEG")
  rawBytes.seek(0)
  img_base64 = base64.b64encode(rawBytes.read())
  imdata['image'] = img_base64
  imdata['width'] = w
  imdata['height'] = h
  return jsonify(imdata)


# delete image
@app.route("/delete/<name>", methods=['DELETE'])
def deleteImg(name):
    print("log: Deleting image {}".format(name) , file = sys.stderr)
    os.remove(imgPath + name)  
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

