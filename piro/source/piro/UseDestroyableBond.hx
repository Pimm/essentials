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
 * A bond that can be destroyed on use. See the Bond class for more information.
 *
 * You should not construct instances of this class directly (unless you are looking for null object behaviour). If you write a
 * class that returns bonds, you will want to use or write a subclass of this one.
 */
class UseDestroyableBond<DerivedType> extends Bond {
	/**
	 * Indicates whether the bond will be destroyed right after it is used (true) or not (false).
	 */
	private var willDestroyOnUse:Bool;
	/**
	 * Destroys the bond right after it is used. Whether this bond has already been used at the moment this method is called does
	 * not matter: the bond will be destroyed on its first use after this method has been called. This method returns this bond
	 * itself.
	 */
	public function destroyOnUse():DerivedType {
		willDestroyOnUse = true;
		return untyped(this);
	}
}
