import sys
import coremltools
import numpy as np
from PIL import Image, ImageDraw
from object_detection import ObjectDetection

MODEL_FILENAME = 'model.mlmodel'
LABELS_FILENAME = 'labels.txt'

class CoreMLObjectDetection(ObjectDetection):
    """Object Detection class for CoreML
    """
    def __init__(self, model, labels):
        super(CoreMLObjectDetection, self).__init__(labels)
        self.model = model

    def predict(self, preprocessed_image):
        outputs = self.model.predict({'data': preprocessed_image})
        return np.squeeze(outputs['model_outputs0']).transpose((1,2,0))

def main(image_filename):
    # Load a CoreML model
    model = coremltools.models.MLModel(MODEL_FILENAME)

    # Load labels
    with open(LABELS_FILENAME, 'r') as f:
        labels = [l.strip() for l in f.readlines()]

    od_model = CoreMLObjectDetection(model, labels)

    image = Image.open(image_filename)
    predictions = od_model.predict_image(image)
    print(predictions)

if __name__ == '__main__':
    if len(sys.argv) <= 1:
        print('USAGE: {} image_filename'.format(sys.argv[0]))
    else:
        main(sys.argv[1])
