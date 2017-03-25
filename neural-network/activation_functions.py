#Imports
import numpy as np
from abc import ABCMeta, abstractmethod
from sys import exit


#Base Class
class activation_function_class(metaclass=ABCMeta):
	@abstractmethod
	def fx(self, z):
		pass

	@abstractmethod
	def fx_prime(self, z):
		pass

	@abstractmethod
	def fx_inverse(self, z):
		pass

#Activation function classes
class max(activation_function_class):
	def fx(self, z):
		f = .5 * (z + abs(z))
		return f

	def fx_prime(self, z):
		if z > 0:
			return 1
		else:
			return 0

	def fx_inverse(self, z):
		print("This function has no inverse")
		pass

class noisy_max(activation_function_class):
	def fx(self, z):
		f = .505*z + .495*abs(z)
		return f

	def fx_prime(self, z):
		if z > 0:
			return 1
		else:
			return 0.01
	def fx_inverse(self, z):
		def core_function(y):
			if y >= 0:
				return y
			else:
				return 100*y
		return np.vectorize(core_function)(z)