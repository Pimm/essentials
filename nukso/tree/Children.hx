package nukso.tree;

/**
 * The children of an element.
 * 
 * Objects of this type are usually constructed by document readers. You only have to implement this interface if you are
 * writing a document reader.
 */
interface Children {
	/**
	 * The direct child elements.
	 */
	public var elements(getElements, never):Iterator<Element>;
	/**
	 * The first direct child, or null if there are no children. This can be either a child element or a text child.
	 */
	public var firstChild(getFirstChild, never):Child;
	/**
	 * The first direct child element, or null if there are no child elements.
	 */
	public var firstElementChild(getFirstElementChild, never):Element;
	/**
	 * The first direct text child, or null if there are no text children.
	 */
	public var firstTextChild(getFirstTextChild, never):String;
	/**
	 * The last direct child, or null if there are no children. This can be either a child element or a text child.
	 */
	public var lastChild(getLastChild, never):Child;
	/**
	 * The last direct child element, or null if there are no child elements.
	 */
	public var lastElementChild(getLastElementChild, never):Element;
	/**
	 * The last direct text child, or null if there are no text children.
	 */
	public var lastTextChild(getLastTextChild, never):String;
	/**
	 * The direct text children.
	 */
	public var texts(getTexts, never):Iterator<String>;
	// When compiling to ActionScript 3, explicitly adding these methods is required. If this is not done, they will not end up
	// in the created interface.
	#if as3
	private function getElements():Iterator<Element>;
	private function getFirstChild():Child;
	private function getFirstElementChild():Element;
	#end
	/**
	 * The first direct child element that has the passed name, or null if such child element does not exist.
	 */
	public function getFirstElementNamed(name:String):Element;
	#if as3
	private function getFirstTextChild():String;
	private function getLastChild():Child;
	private function getLastElementChild():Element;
	private function getLastTextChild():String;
	private function getTexts():Iterator<String>;
	#end
	/**
	 * Creates an iterator that iterates over the direct children, both the text children and the child elements.
	 */
	public function iterator():Iterator<Child>;
}
