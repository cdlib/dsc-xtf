package org.cdlib.xtf.lazyTree;

// IMPORTANT NOTE: When comparing, this file is most similar to 
//                 Saxon's net.sf.tree.NodeImpl

/**
 * Copyright (c) 2004, Regents of the University of California
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *   this list of conditions and the following disclaimer in the documentation 
 *   and/or other materials provided with the distribution.
 * - Neither the name of the University of California nor the names of its
 *   contributors may be used to endorse or promote products derived from this 
 *   software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 */

import java.io.IOException;

import org.w3c.dom.Node;

import net.sf.saxon.pattern.NodeTest;
import net.sf.saxon.pattern.NameTest;
import net.sf.saxon.pattern.AnyNodeTest;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.om.DocumentInfo;
import net.sf.saxon.om.NamePool;
import net.sf.saxon.om.Axis;
import net.sf.saxon.om.AxisIterator;
import net.sf.saxon.om.EmptyIterator;
import net.sf.saxon.om.SingletonIterator;
import net.sf.saxon.om.AbstractNode;
import net.sf.saxon.type.Type;
import net.sf.saxon.event.Receiver;

import org.w3c.dom.Element;

import net.sf.saxon.xpath.XPathException;


/**
  * A node in the XML parse tree representing an XML element, character content, or attribute.<P>
  * This is the top-level class in the implementation class hierarchy; it essentially contains
  * all those methods that can be defined using other primitive methods, without direct access
  * to data.
  * @author Martin Haye
  */
abstract public class NodeImpl extends AbstractNode {

    LazyDocument document;
    int          nodeNum;
    int          nameCode;
    int          parentNum;
    int          prevSibNum;
    int          nextSibNum;
    
    public NodeImpl( LazyDocument document ) {
        this.document = document;
    }
    
    /** Optional initialization function, depends on derived class */
    public void init( int alpha, int beta ) throws IOException { }
    
    /**
    * Set the system ID of this node. This method is provided so that a NodeInfo
    * implements the javax.xml.transform.Source interface, allowing a node to be
    * used directly as the Source of a transformation
     */

    public void setSystemId( String uri ) {
        // overridden in DocumentImpl and ElementImpl
        if( this instanceof AttributeImpl )
            getParent().setSystemId( uri );
        else
            document.setSystemId( nodeNum, uri );
    }

    /**
    * Determine whether this is the same node as another node
    * @return true if this Node object and the supplied Node object represent the
    * same node in the tree.
     */

    public boolean isSameNodeInfo( NodeInfo other ) {
        // default implementation: differs for attribute and namespace nodes   
        if( this==other ) return true;
        if( !(other instanceof NodeImpl) ) return false;
        if( this.document != ((NodeImpl)other).document ) return false;
        if( this.nodeNum != ((NodeImpl)other).nodeNum ) return false;
        if( this.getNodeKind() != other.getNodeKind() ) return false;
        return true;
    }

    /**
     * Get the nameCode of the node. This is used to locate the name in the NamePool
     */
    public int getNameCode() {
        return nameCode;
    }

    /**
    * Get the fingerprint of the node. This is used to compare whether two nodes
    * have equivalent names. Return -1 for a node with no name.
    */

    public int getFingerprint() {
        int nameCode = getNameCode();
        if (nameCode==-1) return -1;
             return nameCode & 0xfffff;
    }

    /**
    * Get a character string that uniquely identifies this node within this document
    * (The calling code will prepend a document identifier)
    * @return a string.
     */
    public String generateId() {
        return document.generateId() + getClass().getName() + nodeNum;
    }
   
	/**
	* Get the node corresponding to this javax.xml.transform.dom.DOMLocator
	*/

    public Node getOriginatingNode() {
        return this;
    }

    /**
    * Get the system ID for the node. Default implementation for child nodes.
     */
    public String getSystemId() {
        return document.getSystemId( nodeNum );
    }

    /**
    * Get the base URI for the node. Default implementation for child nodes.
     */

    public String getBaseURI() {
        return (getParent()).getBaseURI();
    }

    /**
    * Get the node sequence number (in document order). Sequence numbers are monotonic but not
    * consecutive. In the current implementation, parent nodes (elements and roots) have a zero
    * least-significant word, while namespaces, attributes, text nodes, comments, and PIs have
    * the top word the same as their owner and the bottom half reflecting their relative position.
    * This is the default implementation for child nodes.
     */
    protected long getSequenceNumber() {
        return (long)nodeNum << 32;
    }

    /**
    * Determine the relative position of this node and another node, in document order.
    * The other node will always be in the same document.
    * @param other The other node, whose position is to be compared with this node
    * @return -1 if this node precedes the other node, +1 if it follows the other
    * node, or 0 if they are the same node. (In this case, isSameNode() will always
    * return true, and the two nodes will produce the same result for generateId())
     */

    public final int compareOrder( NodeInfo other ) {
        long a = getSequenceNumber();
        long b = ((NodeImpl)other).getSequenceNumber();
        if (a<b) return -1;
        if (a>b) return +1;
        return 0;
    }

    /**
     * Get the NamePool
     */

    public NamePool getNamePool() {
        return document.getNamePool();
    }

    /**
     * Get the prefix part of the name of this node. This is the name before the ":" if any.
    * @return the prefix part of the name. For an unnamed node, return an empty string.
     */

    public String getPrefix() {
        if( nameCode<0 ) 
            return "";
        if( (nameCode>>20 & 0xff) == 0 ) 
            return "";
        return document.getNamePool().getPrefix(nameCode);
    }

    /**
    * Get the URI part of the name of this node. This is the URI corresponding to the
    * prefix, or the URI of the default namespace if appropriate.
    * @return The URI of the namespace of this node. For the default namespace, return an
    * empty string. For an unnamed node, return the empty string.
     */

    public String getURI() {
        if( nameCode < 0 ) 
            return "";
        return document.getNamePool().getURI(nameCode);
    }

    /**
    * Get the display name of this node. For elements and attributes this is [prefix:]localname.
    * For unnamed nodes, it is an empty string.
    * @return The display name of this node.
    * For a node with no name, return an empty string.
    */

    public String getDisplayName() {
        if( nameCode < 0 ) 
            return "";
        return document.getNamePool().getDisplayName(nameCode);
    }

    /**
     * Get the local name of this node.
     *
     * @return The local name of this node. For a node with no name, return "".
     */

    public String getLocalPart() {
        if( nameCode < 0 ) 
            return "";
        return document.getNamePool().getLocalName(nameCode);
    }

    /**
    * Get the line number of the node within its source document entity
    */

    public int getLineNumber() {
        return -1;
    }

    /**
     * Find the parent node of this node.
     * @return The Node object describing the containing element or root node.
     */

    public NodeInfo getParent() {
        return document.getNode( parentNum );
    }

    /**
    * Get the previous sibling of the node
     * @return The previous sibling node. Returns null if the current node is the first
     * child of its parent.
     */

    public Node getPreviousSibling()  {
        return document.getNode( prevSibNum );
    }


    /**
     * Get next sibling node (DOM method)
     * 
     * @return The next sibling node. Returns null if the current node is the last
     * child of its parent.
     */
    public Node getNextSibling()  {
        return document.getNode( nextSibNum );
    }

    /**
    * Get first child - default implementation used for leaf nodes
    * @return null
     */

    public Node getFirstChild()  {
        return null; // overridden in ParentNodeImpl
    }

    /**
    * Get last child - default implementation used for leaf nodes
    * @return null
    */

    public Node getLastChild()  {
        return null;
    }

    /**
    * Return an enumeration over the nodes reached by the given axis from this node
    * @param axisNumber The axis to be iterated over
    * @return an AxisIterator that scans the nodes reached by the axis in turn.
    */

    public AxisIterator iterateAxis( byte axisNumber ) {
        // Fast path for child axis
        if (axisNumber==Axis.CHILD) {
             if (this instanceof ParentNodeImpl) {
                return ((ParentNodeImpl)this).enumerateChildren(null);
             } else {
                return EmptyIterator.getInstance();
             }
        } else {
            return iterateAxis(axisNumber, AnyNodeTest.getInstance());
        }
    }

    /**
    * Return an enumeration over the nodes reached by the given axis from this node
    * @param axisNumber The axis to be iterated over
    * @param nodeTest A pattern to be matched by the returned nodes
    * @return an AxisIterator that scans the nodes reached by the axis in turn.
    */

    public AxisIterator iterateAxis( byte axisNumber, NodeTest nodeTest ) { 

        switch (axisNumber) {
            case Axis.ANCESTOR:
                 return new AncestorEnumeration( this, nodeTest, false );

            case Axis.ANCESTOR_OR_SELF:
                 return new AncestorEnumeration( this, nodeTest, true );

            case Axis.ATTRIBUTE:
                 if( this.getNodeKind() != Type.ELEMENT) return EmptyIterator.getInstance();
                 return new AttributeEnumeration( this, nodeTest );

            case Axis.CHILD:
                 if( this instanceof ParentNodeImpl ) {
                    return ((ParentNodeImpl)this).enumerateChildren(nodeTest);
                 } else {
                    return EmptyIterator.getInstance();
                 }

            case Axis.DESCENDANT:
                if( getNodeKind() == Type.DOCUMENT &&
                    nodeTest instanceof NameTest &&
                    nodeTest.getPrimitiveType() == Type.ELEMENT ) { 
                    return ((LazyDocument)this).getAllElements(
                                nodeTest.getFingerprint());
                } else if (hasChildNodes()) {
                    return new DescendantEnumeration( this, nodeTest, false );
                } else {
                    return EmptyIterator.getInstance();
                }

            case Axis.DESCENDANT_OR_SELF:
                return new DescendantEnumeration( this, nodeTest, true );

            case Axis.FOLLOWING:
                return new FollowingEnumeration( this, nodeTest );

            case Axis.FOLLOWING_SIBLING:
                 return new FollowingSiblingEnumeration( this, nodeTest );

            case Axis.NAMESPACE:
                 if( this.getNodeKind() != Type.ELEMENT ) return EmptyIterator.getInstance();
                 return new NamespaceEnumeration( (ElementImpl)this, nodeTest );

            case Axis.PARENT:
                 NodeInfo parent = (NodeInfo)getParentNode();
                 if( parent == null ) return EmptyIterator.getInstance();
                 if( nodeTest.matches(parent.getNodeKind(), 
                                      parent.getFingerprint(),
                                      parent.getTypeAnnotation()) ) { 
                    return SingletonIterator.makeIterator( parent );
                 }
                 return EmptyIterator.getInstance();

            case Axis.PRECEDING:
                return new PrecedingEnumeration( this, nodeTest );

            case Axis.PRECEDING_SIBLING:
                 return new PrecedingSiblingEnumeration( this, nodeTest );

            case Axis.SELF:
                 if( nodeTest.matches(getNodeKind(), 
                                      getFingerprint(), 
                                      getTypeAnnotation()) ) {
                    return SingletonIterator.makeIterator( this );
                 }
                 return EmptyIterator.getInstance();

            case Axis.PRECEDING_OR_ANCESTOR:
                 return new PrecedingOrAncestorEnumeration( this, nodeTest );

            default:
                 throw new IllegalArgumentException("Unknown axis number " + axisNumber);
        }
    }

    /**
     * Returns whether this node (if it is an element) has any attributes.
     * @return <code>true</code> if this node has any attributes,
     *   <code>false</code> otherwise.
     * @since DOM Level 2
     */

    public boolean hasAttributes() {
        // overridden in LazyElementImpl
        return false;
    }

    /**
     * Find the value of a given attribute of this node. <BR>
     * This method is defined on all nodes to meet XSL requirements, but for nodes
     * other than elements it will always return null.
     * @param uri the namespace uri of an attribute
     * @param localName the local name of an attribute
     * @return the value of the attribute, if it exists, otherwise null
     */

//    public String getAttributeValue( String uri, String localName ) {
//        return null;
//    }

    /**
     * Find the value of a given attribute of this node. <BR>
     * This method is defined on all nodes to meet XSL requirements, but for nodes
     * other than elements it will always return null.
     * @param name the name of an attribute. This must be an unqualified attribute name,
     * i.e. one with no namespace prefix.
     * @return the value of the attribute, if it exists, otherwise null
     */

//    public String getAttributeValue( String name ) {
//        return null;
//    }

    /**
    * Get the value of a given attribute of this node
    * @param fingerprint The fingerprint of the attribute name
    * @return the attribute value if it exists or null if not
    */

    public String getAttributeValue(int fingerprint) {
    	return null;
    }

    /**
     * Get the outermost element.
     * @return the Element node for the outermost element of the document. If the document is
     * not well-formed, this returns the last element child of the root if there is one, otherwise
     * null.
     */

    public Element getDocumentElement() {
        return ((LazyDocument)getDocumentRoot()).getDocumentElement();

    }

    /**
    * Get the root node
    * @return the NodeInfo representing the containing document
     */

    public NodeInfo getRoot() {
        return getDocumentRoot();
    }

    /**
     * Get the root (document) node
     * @return the DocumentInfo representing the containing document
     */

    public DocumentInfo getDocumentRoot() {
        return document.getDocumentRoot();
    }

    /**
     * Get the next node in document order
    * @param anchor the scan stops when it reaches a node that is not a descendant of the specified
    * anchor node
     * @return the next node in the document, or null if there is no such node
     */

    public NodeImpl getNextInDocument( NodeImpl anchor ) {
        // find the first child node if there is one; otherwise the next sibling node
        // if there is one; otherwise the next sibling of the parent, grandparent, etc, up to the anchor element.
        // If this yields no result, return null.

        NodeImpl next = (NodeImpl)getFirstChild();
        if( next != null ) return next;
        if( this == anchor ) return null;
        next = (NodeImpl)getNextSibling();
        if( next != null ) return next;
        NodeImpl parent = this;
        while( true ) {
            parent = (NodeImpl)parent.getParent();
            if( parent == null ) return null;
            if( parent == anchor ) return null;
            next = (NodeImpl)parent.getNextSibling();
            if( next != null ) return next;
        }
    }
    

    /**
     * Get the previous node in document order
    * @return the previous node in the document, or null if there is no such node
     */
    public NodeImpl getPreviousInDocument() {

        // finds the last child of the previous sibling if there is one;
        // otherwise the previous sibling element if there is one;
        // otherwise the parent, up to the anchor element.
        // If this reaches the document root, return null.

        NodeImpl prev = (NodeImpl)getPreviousSibling();
        if( prev != null ) return prev.getLastDescendantOrSelf();
        return (NodeImpl)getParentNode();
    }
    
    /**
     * Get the last descendant of this node, or if it has no descendants,
     * return the node itself.
     */
    private NodeImpl getLastDescendantOrSelf() {
        NodeImpl last = (NodeImpl)getLastChild();
        if( last == null ) return this;
        return last.getLastDescendantOrSelf();
    }

    /**
     * Output all namespace nodes associated with this element. Does nothing if
     * the node is not an element.
     * @param out The relevant outputter
     * @param includeAncestors True if namespaces declared on ancestor elements must
     * be output; false if it is known that these are already on the result tree
     */

    public void outputNamespaceNodes( Receiver out, boolean includeAncestors )
        throws XPathException
    {}

    /**
    * Copy nodes. Copying type annotations is not yet supported for this tree
    * structure, so we simply map the new interface onto the old
    */

    public abstract void copy(Receiver out, int whichNamespaces, boolean copyAnnotations, int locationId) throws XPathException;
    
     // implement DOM Node methods

    /**
     * Determine whether the node has any children.
     * @return  <code>true</code> if the node has any children,
     *   <code>false</code> if the node has no children.
     */

    public boolean hasChildNodes() {
        // overridden in ParentNodeImpl
        return false;
    }

}

