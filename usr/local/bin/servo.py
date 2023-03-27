#import RPi.GPIO as GPIO
from time import sleep
import sys
import wiringpi

if len(sys.argv) < 2 or  len(sys.argv) > 2:
    print "Usage: servo.py angle  */ range (15,70)"
    sys.exit(0)

wiringpi.piBoardRev()

pin_nr=18
supply_pin_nr=23

#init
# use 'GPIO naming'
wiringpi.wiringPiSetupGpio()

#init pwm
#For the Raspberry Pi PWM module, the PWM Frequency in Hz = 19,200,000 Hz / pwmClock / pwmRange
#If pwmClock is 192 and pwmRange is 2000 we'll get the PWM frequency = 50 Hz

# set #18 to be a PWM output
wiringpi.pinMode(pin_nr, wiringpi.GPIO.PWM_OUTPUT)
 
# set the PWM mode to milliseconds stype
wiringpi.pwmSetMode(wiringpi.GPIO.PWM_MODE_MS)
 
# divide down clock
wiringpi.pwmSetClock(192)
wiringpi.pwmSetRange(2000)


#init supply pin
#wiringpi.pinMode(supply_pin_nr, 1) #output
wiringpi.pinMode(supply_pin_nr, wiringpi.GPIO.OUTPUT)



def SetAngle(duty):
 #1ms 0 deg, 2ms - 180 degrees (50-200 duty value)
 print "Setting duty cycle value to:", duty
 wiringpi.pwmWrite(pin_nr,duty)
 sleep(1)
 #enable supply of servo
 wiringpi.digitalWrite(supply_pin_nr, 1)
 sleep(1)
 #disable supply of servo
 wiringpi.digitalWrite(supply_pin_nr, 0)
 #disable PWM
 wiringpi.pwmWrite(pin_nr,0)

param = int(sys.argv[1])
if param < 60 or param > 120:
    print "Usage: servo.py duty  [60,120]"
    sys.exit(0)

SetAngle(param)
sleep(1)

#cleanup
#set ports to input with pulldown resistor
wiringpi.pinMode(supply_pin_nr, wiringpi.GPIO.INPUT)
wiringpi.pullUpDnControl(supply_pin_nr,wiringpi.GPIO.PUD_DOWN)

wiringpi.pinMode(pin_nr, wiringpi.GPIO.INPUT)
wiringpi.pullUpDnControl(pin_nr,wiringpi.GPIO.PUD_DOWN)
