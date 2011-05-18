import haxe.Timer;
import piro.Async;
import piro.Bond;
using piro.Async;

class Main {
	public static function main():Void {
		// Create the random number array.
		var numbers:Array<Int> = new Array();
		for (number in 0...16) {
			numbers.insert(Math.floor((1 + number) * Math.random()), number);
		}
		trace(numbers);
		// Wire the function that will turn the index into a message.
		var targetIndex:Async<Int> = new Async(Main);
		var message:Async<String> = function(value:Int):String {
			return if (0 > value) {
				if (-1 == value) {
					"The number 7 was found 1 place from the end.";
				} else {
					"The number 7 was found " + -value + " places from the end.";
				}
			} else {
				if (1 == value) {
					"The number 7 was found 1 place from the start.";
				} else {
					"The number 7 was found " + value + " places from the start.";
				}
			}
		}.wait(targetIndex).result;
		// Wire the function that will trace the message.
		function(value:String):Void {
			trace(value);
		}.wait(message);
		// Find 7, starting from the start and from the end.
		var backwardBond:Bond = null;
		var forwardBond:Bond = function(index:Int):Void {
			targetIndex.yield(index);
			// Prevent the backward finding from tracing, too.
			backwardBond.destroy();
		}.wait(new ForwardOccurrenceFinder().find(numbers, 7));
		backwardBond = function(index:Int):Void {
			targetIndex.yield(-index);
			// Prevent the forward finding from tracing, too.
			forwardBond.destroy();
		}.wait(new BackwardOccurrenceFinder().find(numbers, 7));
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
		var timer:Timer = new Timer(100);
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
