using jjd.Async;
import jjd.Async;
import jjd.Bond;
class Demo {

	public static function main(){
		var as_int = new Async<Int>(); 
		var delay = function() as_int.yield(5);
		var haxetimer = haxe.Timer.delay(delay,5000);
		var other_int = function(x:Int){ 
			trace("I saw: "+ x + ", added one to it, and passed it on");
			return x+1;
		}.wait(as_int);
		
		var b_int = function(x:Int){ 
			trace("I saw: "+x);
		}.bind(other_int);
		
		b_int.halt(); // comment this to trigger the bind call.
		
		var multi_arg_bond = function (x:Int, y:Int){
			trace("x: " + Std.string(x)); 
			trace("y: " + Std.string(y)); 
		}.bind(4.toAsync(), 4.toAsync());
		
	}
}