package nukso.tree;

/**
 * A null object implementation of the children interface. This implementation can be used instead of an empty list of
 * children, to save resources.
 * 
 * Objects of this type are usually constructed by document readers.
 */
class NullChildren implements Children {
	public function new():Void {
	}
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
	private function getElements():Iterator<Element> {
		return this;
	}
	private function getFirstChild():Child {
		return null;
	}
	private function getFirstElementChild():Element {
		return null;
	}
	public function getFirstElementNamed(name:String):Element {
		return null;
	}
	public function iterator():Iterator<Child> {
		return this;
	}
	private function getFirstTextChild():String {
		return null;
	}
	private function getLastChild():Child {
		return null;
	}
	private function getLastElementChild():Element {
		return null;
	}
	private function getLastTextChild():String {
		return null;
	}
	private function getTexts():Iterator<String> {
		return this;
	}
	public function hasNext():Bool {
		return false;
	}
	public function next():Dynamic {
		return null;
	}
}
