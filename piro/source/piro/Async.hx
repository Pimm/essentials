/**
 * Copyright (c) 2009-2011, the essentials team.
 *
 * This file is part of Piro. Piro is the essential haXe library for event-driven programming.
 *
 * Piro is free software: you may redistribute and/or modify this file providing that the following condition is met:
 *	* Redistributions of this software in source form must retain or reproduce the above copyright notice, this condition and
 *	  the following disclaimer.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HSL CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
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
 * downloaded from the Internet; or the contents of a form the user is currently filling in.
 */
class Async<Type> {
	/**
	 * A fake bond before the first real bond and after the last real one.
	 */
	private var sentinel:AsyncBond<Type>;
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
	 * Cancels the notification of the passed listener when this value is filled in. This method reverses the effect of the
	 * notify method.
	 * 
	 * If the passed listener is not registered to be notified, calling this method has no effect. If the passed listener is
	 * registered to be notified more than once, only one registration will be removed.
	 */
	public function cancel(listener:Type -> Dynamic):Void {
		// Find the matching bond.
		if (null != sentinel) {
			var bond:AsyncBond<Type> = sentinel.next;
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
	/**
	 * Notifies the passed listener when this value is filled in. If this value has already been filled in, the passed listener
	 * will be notified immediately, synchronous, without delay. So note that the listener you pass might be notified directly.
	 * 
	 * Returns a bond that represents the connection between this asynchronous value and the passed listener. This connection can
	 * broken either by calling the cancel method of the asynchronous value, or the destroy method of the returned bond.
	 * 
	 * Listeners will be notified in the order in which they are added.
	 */
	public function notify(listener:Type -> Dynamic):Bond {
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
			// Return a bond that does nothing, also known as a null object. This is better than actually returning null, because
			// if this method would return null, the caller would have to perform a null check.
			return new Bond();
		// If this value has not yet been yielded create a bond that contains the listener, so the listener can be notified as soon
		// as this value is yielded.
		} else {
			var bond:AsyncBond<Type> = new AsyncBond();
			bond.listener = listener;
			// Link the newly created bond.
			if (null == sentinel) {
				bond.next = bond.previous = sentinel = new AsyncBond<Type>();
				sentinel.next = sentinel.previous = bond;
			} else {
				bond.next = sentinel;
				bond.previous = sentinel.previous;
				sentinel.previous = sentinel.previous.next = bond;
			}
			// Return the bond.
			return bond;
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
	 * Yields, fills in, the value. This method may only be called by the yielder.
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
			var bond:AsyncBond<Type> = sentinel.next;
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
 * A linked bond used by the Async class.
 */
class AsyncBond<Type> extends Bond {
	/**
	 * Whether this bond has been destroyed (false) or not (true).
	 */
	private var inUse:Bool;
	/**
	 * The actual listener, or null if this bond is the sentinel.
	 */
	public var listener:Type -> Dynamic;
	/**
	 * A reference to the next bond.
	 */
	public var next:AsyncBond<Type>;
	/**
	 * A reference to the previous bond.
	 */
	public var previous:AsyncBond<Type>;
	/**
	 * Creates a new Async bond.
	 */
	public function new():Void {
		super();
		inUse = true;
	}
	public override function destroy():Void {
		// The actual logic for this implementation of the destroy method is in the unlink method. This way, the sentinel can call
		// unlink directly, which is inlined.
		unlink();
	}
	public inline function unlink():Void {
		// If this bond has already been destroyed, don't destroy it again.
		if (inUse) {
			previous.next = next;
			next.previous = previous;
			listener = null;
			inUse = false;
		}
	}
}
class WaitFor1 {
	/**
	 * Notifies this function when the passed asynchronous value is filled in. If the passed asynchronous value has already been
	 * filled in, this function will be notified immediately, synchronous, without delay. So note that this function might be
	 * notified directly.
	 * 
	 * Returns a bond that represents the connection between the passed asynchronous value and this function. This connection can
	 * be broken either by calling the destroy method of the returned bond.
	 */
	public static inline function waitFor<Type>(listener:Type -> Dynamic, value:Async<Type>):Bond {
		return value.notify(listener);
	}
}
/**
 * A linked bond used by the WaitFor2 class.
 */
class WaitFor2Bond<FirstType, SecondType> extends Bond {
	/**
	 * The bond between the callListenerIfYielded method of this bond and the first asynchronous value.
	 */
	private var firstBond:Bond;
	/**
	 * The first asynchronous value.
	 */
	private var firstValue:{var value:FirstType; var yielded:Bool;};
	/**
	 * The actual listener, or null if this bond is the sentinel.
	 */
	public var listener:FirstType -> SecondType -> Dynamic;
	/**
	 * The bond between the callListenerIfYielded method of this bond and the second asynchronous value.
	 */
	private var secondBond:Bond;
	/**
	 * The second asynchronous value.
	 */
	private var secondValue:{var value:SecondType; var yielded:Bool;};
	/**
	 * Creates a new WaitFor2 bond.
	 */
	public function new(listener:FirstType -> SecondType -> Dynamic, firstValue:Async<FirstType>, secondValue:Async<SecondType>):Void {
		super();
		this.listener = listener;
		this.firstValue = untyped firstValue;
		this.secondValue = untyped secondValue;
		// Call the callListenerIfYielded method directly, just in case both asynchronous values are aleady yielded.
		if (notifyListenerIfYielded()) {
			firstBond = firstValue.notify(notifyListenerIfYielded);
			secondBond = secondValue.notify(notifyListenerIfYielded);
		}
	}
	/**
	 * Notifies the listener if both values are yielded. Returns false if the listener has been notified.
	 */
	private inline function notifyListenerIfYielded(?bogus:Dynamic):Bool {
		if (firstValue.yielded && secondValue.yielded) {
			listener(firstValue.value, secondValue.value);
			firstValue = null;
			secondValue = null;
			listener = null;
			return false;
		} else {
			return true;
		}
	}
	public override function destroy():Void {
		if (null != firstBond) {
			firstBond.destroy();
			secondBond.destroy();
			firstValue = null;
			secondValue = null;
			listener = null;
		}
	}
}
class WaitFor2 {
	/**
	 * Notifies this function when both of the passed asynchronous values are filled in. If both of the passed asynchronous
	 * values have already been filled in, this function will be notified immediately, synchronous, without delay. So note that
	 * this function might be notified directly.
	 * 
	 * Returns a bond that represents the connection between the passed asynchronous values and this function. This connection
	 * can be broken either by calling the destroy method of the returned bond.
	 */
	public static inline function waitFor<FirstType, SecondType>(listener:FirstType -> SecondType -> Dynamic, firstValue:Async<FirstType>, secondValue:Async<SecondType>):Bond {
		return new WaitFor2Bond(listener, firstValue, secondValue);
	}
}
