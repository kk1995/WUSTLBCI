import numpy as np
from numpy.linalg import inv
import pdb
import math
import time
import gzip
import pickle
import matplotlib.cm as cm
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import os
from skimage import color
import openpyxl
import abc
import activation_functions
import net
from PIL import Image
from openpyxl import load_workbook

#Neural Network Runtime Implementation
t, v, test = net.load_data_wrapper()
#plt.imshow(t[3][0].reshape((28,28)), cmap=cm.Greys_r)
#plt.show()
net.save_vector_to_image(vector=t[1][0], shape=(28,28), file="image.png")
#im = Image.fromarray(t[0][0].reshape((28,28)), 'RGB')
#im.save('image.png')
# print('The input' + str(t[0][0]))
# val_data = np.array(np.column_stack(v).transpose()[0]).transpose()
# print(val_data)
#print(v[0][0])
#toy_set = load_data_from_file('test.txt')
n = net.NeuralNetwork(layers=[784,30,10],learningrate=0.005, lmb=0.0, sample_size=20, training_data=t, 
	probability=0.5, momentum=0.5)
#print("Initial training set accuracy is: " + str(accuracy_test(n, t)))
#print("Initial validation set accuracy is: " + str(accuracy_test(n, v)))
#print("Starting...")d
#n.load("save_file.xlsx")
print("Accuracy rate of training set is: " + str(net.accuracy_test(n, t)))
n.train(epochs=100)
four_image = net.image_to_vector("4.png").reshape((784,1))
five_image = net.image_to_vector("5.png").reshape((784,1))
six_image = net.image_to_vector("6.png").reshape((784,1))
#plt.imshow(six_image.reshape((28,28)), cmap=cm.Greys_r)
##plt.show()
# print([np.transpos# e(bias) for bias in n.biases]
print("Accuracy rate of training set is: " + str(net.accuracy_test(n, t)))
print("Accuracy rate of validation set is:  " + str(net.accuracy_test(n, v)))
print("Accuracy rate of test set is: " + str(net.accuracy_test(n, test)))
four_result = np.argmax(n.run(four_image.reshape(1,784))[-1])
five_result = np.argmax(n.run(five_image.reshape(1,784))[-1])
six_result = np.argmax(n.run(six_image.reshape(1,784))[-1])
print(str(four_result))
print(str(five_result))
print(str(six_result))
#n.show_results(v)
#n.save("save_file.xlsx")