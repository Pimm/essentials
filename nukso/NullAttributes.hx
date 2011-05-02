package nukso;

/**
 * A null object implementation of the attributes interface. This implementation can be used instead of an empty attributes
 * object, to save resources.
 */
class NullAttributes implements Attributes {
	public var names(keys, never):Iterator<String>;
	public function new():Void {
	}
	public function get(name:String):Null<String> {
		return null;
	}
	public function hasNext():Bool {
		return false;
	}
	private function keys():Iterator<String> {
		return this;
	}
	public function next():String {
		return null;
	}
	#if debug
	private function toString():String {
		return "[Attributes]";
	}
	#end
}
