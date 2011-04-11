import haxe.Timer;
import piro.Async;
import piro.Bond;
using piro.Async;

class Main {
	public static function main():Void {
		// Create the random number array.
		var numbers:Array<Int> = new Array();
		for (number in 0...16) {
			numbers.insert(Math.floor(number * Math.random()), number);
		}
		trace(numbers);
		// Create the asyncronous value for the tracable method.
		var message:Async<String> = new Async(Main);
		function(value:String):Void {
			trace(value);
		}.wait(message);
		// Find 7, starting from the start and from the end.
		var forwardBond:Bond = new BondHolder();
		var backwardBond:Bond = new BondHolder();
		function(index:Int):Void {
			message.yield("The number 7 was found " + index + " places from the start.");
			// Prevent the backward finding from tracing, too.
			backwardBond.destroy();
		}.wait(new ForwardOccurrenceFinder().find(numbers, 7), forwardBond);
		function(index:Int):Void {
			message.yield("The number 7 was found " + index + " places from the end.");
			// Prevent the forward finding from tracing, too.
			forwardBond.destroy();
		}.wait(new BackwardOccurrenceFinder().find(numbers, 7), backwardBond);
	}
}
class OccurrenceFinder {
	public function new():Void {
	}
	private function determineMatch(array:Array<Int>, targetNumber:Int, index:Int):Bool {
		return false;
	}
	public function find(array:Array<Int>, targetNumber:Int):Async<Int> {
		var result:Async<Int> = new Async(this);
		var currentIndex:Int = 0;
		var timer:Timer = new Timer(1);
		var determineMatch:Array<Int> -> Int -> Int -> Bool = determineMatch;
		timer.run = function():Void {
			if (determineMatch(array, targetNumber, currentIndex)) {
				result.yield(currentIndex);
				timer.stop();
			} else {
				currentIndex++;
			}
		}
		return result;
	}
}
class ForwardOccurrenceFinder extends OccurrenceFinder {
	public function new():Void {
		super();
	}
	private override function determineMatch(array:Array<Int>, targetNumber:Int, index:Int):Bool {
		return array[index] == targetNumber;
	}
}
class BackwardOccurrenceFinder extends OccurrenceFinder {
	public function new():Void {
		super();
	}
	private override function determineMatch(array:Array<Int>, targetNumber:Int, index:Int):Bool {
		return array[array.length - index - 1] == targetNumber;
	}
}
