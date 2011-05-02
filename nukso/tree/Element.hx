package nukso.tree;

/**
 * An element.
 */
class Element {
	/**
	 * The attributes of this element.
	 */
	public var attributes(default, null):Attributes;
	/**
	 * The children of this element.
	 */
	public var children(default, null):Children;
	/**
	 * The name of this element.
	 */
	public var name(default, null):String;
	public function new(name:String, attributes:Attributes, children:Children):Void {
		this.name = name;
		this.attributes = attributes;
		this.children = children;
	}
	#if debug
	private function toString():String {
		return "[Element name=\"" + name + "\" attributes=" + attributes + " children=\"" + children + "\"]";
	}
	#end
}
