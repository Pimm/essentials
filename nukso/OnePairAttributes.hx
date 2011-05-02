package nukso;

/**
 * An implementation of the attributes interface that contains only one name-value pair.
 */
class OnePairAttributes implements Attributes {
	public var names(keys, never):Iterator<String>;
	/**
	 * The name of the name-value pair.
	 */
	public var pairName:String;
	/**
	 * Whether the internal pair has already been read. Determines the value returned by the hasNext method.
	 */
	private var pairRead:Bool;
	/**
	 * The value of the name-value pair.
	 */
	private var pairValue:String;
	public function new(pairName:String, pairValue:String):Void {
		this.pairName = pairName;
		this.pairValue = pairValue;
	}
	public function get(name:String):Null<String> {
		// Check whether the passed name is the name of the name-value pair. If not, return null.
		if (pairName == name) {
			return pairValue;
		} else {
			return null;
		}
	}
	public function hasNext():Bool {
		// If the internal pair has already been read, return false, as that is the only value.
		if (pairRead) {
			return false;
		// If not, set the pairRead property to true, so this method returns false the next time.
		} else {
			pairRead = true;
			return true;
		}
	}
	public function keys():Iterator<String> {
		pairRead = false;
		return this;
	}
	public function next():String {
		return pairName;
	}
	#if debug
	public function toString():String {
		return "[Attributes " + pairName + "=\"" + pairValue + "\"]";
	}
	#end
}
