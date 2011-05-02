package nukso.tree;

/**
 * A child of an element.
 */
enum Child {
	/**
	 * A child element.
	 */
	element(value:Element);
	/**
	 * A text child.
	 */
	text(value:String);
}
