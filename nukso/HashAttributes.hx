package nukso;
#if (as3 || flash9)
import flash.utils.Dictionary;
#end

/**
 * A hash-based implementation of the attributes interface.
 */
class HashAttributes #if !(as3 || flash9) extends Hash<String>, #end implements Attributes {
	// As you can see, this class extends Hash<String>. However, since ActionScript 3 does not support generics in this way, the
	// ActionScript 3 version of the haXe Hash class has star (*) types everywhere. Because of all these star types instead of
	// the String type we'd all expect, this class would not implement the Attributes interface correctly. Therefore this class
	// uses the Dictionary class when compiling to AS3.
	#if (as3 || flash9)
	private var dictionary:Dictionary;
	public function new():Void {
		dictionary = new Dictionary();
	}
	#end
	/**
	 * The names of the available name-value pairs.
	 */
	public var names(keys, never):Iterator<String>;
	#if (as3 || flash9)
	public function get(name:String):Null<String> {
		return untyped(dictionary)[name];
	}
	private function keys():Iterator<String> {
		// Calling the iterator method on the object returned by __keys__ doesn't seem to do the trick. It will result in "Error
		// #1006: iterator is not a function."
		var keys:Array<String> = untyped __keys__(dictionary);
		var currentKeyIndex:Int = 0;
		var keyCount:Int = keys.length;
		return {
			hasNext: function():Bool {
				return currentKeyIndex < keyCount;
			},
			next: function():String {
				return keys[currentKeyIndex++];
			}
		}
	}
	public inline function set(name:String, value:String):Void {
		untyped(dictionary)[name] = value;
	}
	#end
	#if (debug && !(as3 || flash9))
	public override function toString():String {
		var result:String = "[Attributes";
		for (key in keys()) {
			result += " " + key + "=\"" + get(key) + "\"";
		}
		return result + "]";
	}
	#end
}