/**
 * Copyright (c) 2009-2011, the essentials team.
 *
 * This file is part of Piro. Piro is the essential haXe library for event-driven programming.
 *
 * Piro is free software: you may redistribute and/or modify this file providing that the following condition is met:
 *	* Redistributions of this software in source form must retain or reproduce the above copyright notice, this condition and
 *	  the following disclaimer.
 *
 * THIS SOFTWARE IS PROVIDED BY THE ESSENTIALS TEAM "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * ESSENTIALS TEAM BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Alternatively, this file may be used under the terms of either the X11/MIT License, the Simplified BSD License,
 * the GNU Lesser General Public License Version 2.1 or later or the GNU General Public License Version 2 or later, in which
 * case the provisions of that license are applicable instead of those above.
 */
package piro;

/**
 * An asynchronous value. A value that will be filled in at some point in the future, such as a document that is being
 * downloaded from the Internet; or the contents of a form the user might still be filling in.
 * 
 * You should construct instances of this class wherever you want to return asynchronous values.
 */
class Async<Type> {
	/**
	 * A fake bond before the first real bond and after the last real one.
	 */
	private var sentinel:LinkedBond<Type>;
	/**
	 * The value of this asynchronous value wrapper.
	 */
	private var value:Type;
	/**
	 * Whether this value has been yielded yet (true) or not (false).
	 */
	private var yielded:Bool;
	#if !production
	/**
	 * The class names of the yielder passed in the constructor.
	 */
	private var yielderClassNames:List<String>;
	#end
	/**
	 * Creates a new asynchronous value.
	 *
	 * Only the passed yielder is allowed to call the yield method.
	 */
	public function new(yielder:Yielder):Void {
		#if !production
		// Save the class names of the yielder.
		yielderClassNames = TypeTools.getClassNames(yielder);
		#end
	}
	/**
	 * Notifies the passed listener as soon as this value is filled in. If this value has already been filled in, the passed
	 * listener will be notified immediately, synchronous, without delay. So note that the listener you pass might be notified
	 * directly.
	 *
	 * Returns the bond between this value and the passed listener. You can use that bond to unbind this value and the passed
	 * listener by calling the destroy method.
	 *
	 * Listeners will be notified in the order in which they are added.
	 */
	public function bind(listener:Type -> Dynamic):Bond {
		#if !production
		// If the passed listener is null, throw an exception. Having null for a listener will produce errors when the value is
		// yielded.
		if (null == listener) {
			throw "Argument listener must be non-null";
		}
		#end
		// If this value is already yielded, notify the listener immediately.
		if (yielded) {
			listener(value);
			return new Bond();
		// If this value has not yet been yielded create a bond that contains the listener, so the listener can be notified as soon
		// as this value is yielded.
		} else {
			var bond:LinkedBond<Type> = new LinkedBond();
			bond.listener = listener;
			// Link the newly created bond.
			if (null == sentinel) {
				bond.next = bond.previous = sentinel =
					// In case of JavaScript, use this shortcut which skips the constructor (to make it a bit faster).
					#if js
					untyped __new__(LinkedBond, __js__("$_"));
					#else
					new LinkedBond();
					#end
				sentinel.next = sentinel.previous = bond;
			} else {
				bond.next = sentinel;
				bond.previous = sentinel.previous;
				sentinel.previous = sentinel.previous.next = bond;
			}
			return bond;
		}
	}
	/**
	 * Cancels the notification of the passed listener when this value is filled in. This method reverses the effect of the
	 * bind method.
	 *
	 * If the passed listener is not registered to be notified, calling this method has no effect. If the passed listener is
	 * registered to be notified more than once, only one registration will be removed.
	 */
	public function unbind<ReturnType>(listener:Type -> ReturnType):Void {
		// Find the matching bond.
		if (null != sentinel) {
			var bond:LinkedBond<Type> = sentinel.next;
			while (null != bond.listener) {
				// If the matching bond is found, unlink it.
				if (Reflect.compareMethods(bond.listener, listener)) {
					bond.unlink();
					return;
				}
				bond = bond.next;
			}
		}
	}
	#if debug
	private function toString():String {
		return "[Async]";
	}
	#end
	#if !production
	/**
	 * Checks whether the class name inside the passed position information equals the class name of the yielder as passed in the
	 * constructor. Used in the yield method, as that method may only be called by the yielder.
	 *
	 * Two notes.
	 * One, by using this method you check whether the caller is of the same type as the yielder, which does not necessarily mean
	 * it's the same instance. This is the expected behavior, as it is consistent with private members.
	 * Two, one could hack his or her way around this check. How to do this should be obvious. The check is not designed to be
	 * unhackable; rather it is designed to prevent developers from accidentally misapplying this class. Nicolas Cannasse once
	 * said "everything should be made accessible, if you know what you're doing".
	 */
	private function verifyCaller(positionInformation:haxe.PosInfos):Void {
		for (yielderClassName in yielderClassNames) {
			if (yielderClassName == positionInformation.className) {
				return;
			}
		}
		throw "This method may only be called by the yielder.";
	}
	#end
	/**
	 * Fills in the value. This method may only be called by the yielder.
	 *
	 * If this method has been called before, calling this method has no effect.
	 *
	 * If there are listeners registered to be notified when this value is filled in, they will be notified.
	 */
	#if production
	public function yield(value:Type):Void {
	#else
	public function yield(value:Type, ?positionInformation:haxe.PosInfos):Void {
		// Verify that the caller of this method is the yielder.
		verifyCaller(positionInformation);
	#end
		// If this value has already been yielded, return directly.
		if (yielded) {
			return;
		}
		// Save the value and set the yielded flag, for future calls to the notify method.
		this.value = value;
		yielded = true;
		// Notify the listeners through the bonds.
		if (null != sentinel) {
			var bond:LinkedBond<Type> = sentinel.next;
			while (null != bond.listener) {
				bond.listener(value);
				bond = bond.next;
			}
			// Remove the references to the bonds. They are no longer needed.
			sentinel = null;
		}
	}
}
/**
 * An object that yields an asynchronous value.
 */
typedef Yielder = {}
/**
 * A linked bond used internally by asynchronous values.
 */
class LinkedBond<Type> extends Bond {
	/**
	 * Whether this bond has been destroyed (true) or not (false).
	 */
	private var destroyed:Bool;
	/**
	 * The actual listener, or null if this bond is the sentinel.
	 */
	public var listener:Type -> Void;
	/**
	 * A reference to the next bond.
	 */
	public var next:LinkedBond<Type>;
	/**
	 * A reference to the previous bond.
	 */
	public var previous:LinkedBond<Type>;
	public override function destroy():Void {
		// If this bond has already been destroyed, don't destroy it again.
		destroyed || untyped(unlink());
	}
	public function unlink():Void {
		previous.next = next;
		next.previous = previous;
		destroyed = true;
		// Clean up the mess, help the garbage collector.
		listener = null;
		previous = next = null;
	}
}
