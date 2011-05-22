import haxe.Timer;
import piro.Async;
import piro.Bond;
import piro.Signal;
import piro.Sync;
using Piro;

class Main {
	public static function main():Void {
		new Main();
	}
	public function new():Void {
		// Create the three asynchronous numbers.
		var firstNumber:Async<Int> = new Async(this);
		var thirdNumber:Async<Int> = new Async(this);
		// Find the greatest common divisor of the three numbers. As you can see, there's a synchronous value in there. We mix up
		// those things, it ain't a thing.
		var greatestCommonDivisor:Async<Int> = findGreatestCommonDivisor3.wait(firstNumber, new Sync(1908), thirdNumber).result;
		// Trace the greatest common divisor.
		function(value:Int):Void {
			trace("The greatest common divisor is " + value);
		}.wait(greatestCommonDivisor);
		// Fill in the asynchronous numbers.
		firstNumber.yield(3546);
		thirdNumber.yield(8640);
	}
	private static function findGreatestCommonDivisor2(a:Int, b:Int):Int {
		return if (0 == b) {
				a;
			} else {
				findGreatestCommonDivisor2(b, a % b);
			}
	}
	private static function findGreatestCommonDivisor3(a:Int, b:Int, c:Int):Async<Int> {
		var result:Async<Int> = new Async(Main);
		Timer.delay(function():Void {
			result.yield(findGreatestCommonDivisor2(findGreatestCommonDivisor2(a, b), c));
		}, 500);
		return result;
	}
}
class Villian {
	public var laserShotSignal:Signal<Void>;
	public function new():Void {
		laserShotSignal = new Signal(this);
	}
	public function shootLaser():Void {
		laserShotSignal.dispatch();
	}
}
