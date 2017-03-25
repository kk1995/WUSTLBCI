// Tiny bit of mod from Kenny Kim

using System;
using SharpOSC;
using System.Net.Sockets;
using System.Net;

namespace muse_osc_server
{
	class MainClass
	{
		public static void Main(string[] args)
		{
            IPAddress ip = IPAddress.Parse("172.27.170.87");
			// Callback function for received OSC messages. 
			// Prints EEG and Relative Alpha data only.
			HandleOscPacket callback = delegate(OscPacket packet)
			{
				var messageReceived = (OscMessage)packet;
				var addr = messageReceived.Address;
				if(addr == "/muse/eeg") {

                    Console.Write("EEG values: ");
					foreach(var arg in messageReceived.Arguments) {
						Console.Write(arg + " ");
					}
                    Console.WriteLine();
				}
				if(addr == "/muse/elements/alpha_relative") {
                    Console.Write("Relative Alpha power values: ");
					foreach(var arg in messageReceived.Arguments) {
						Console.Write(arg + " ");
					}
                    Console.WriteLine();
                }
			};

            // Create an OSC server.

            var listener = new UDPListener(5000, callback);
            //listener.Start();
			Console.WriteLine("Press enter to stop");
			Console.ReadLine();
            // listener.Stop();
		}
	}
}