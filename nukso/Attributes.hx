package nukso;

/**
 * The attributes of an element. The interface is optimised for hash-based implementations.
 */
interface Attributes {
	/**
	 * The names of the available name-value pairs.
	 */
	public var names(keys, never):Iterator<String>;
	/**
	 * Returns the value associated to the passed name, or null if the passed name does not exist.
	 */
	public function get(name:String):Null<String>;
	// When compiling to ActionScript 3, explicitly adding this method is required. If this is not done, it will not end up in
	// the created interface.
	#if as3
	private function keys():Iterator<String>;
	#end
}