package org.cdlib.xtf.textEngine;

import java.io.File;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.TreeSet;
import java.util.Vector;

import javax.xml.transform.Source;

import net.sf.saxon.Configuration;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.TreeBuilder;

import org.apache.lucene.chunk.SpanChunkedNotQuery;
import org.apache.lucene.chunk.SpanDechunkingQuery;
import org.apache.lucene.index.Term;
import org.apache.lucene.mark.SpanDocument;
import org.apache.lucene.search.BooleanClause;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.spans.SpanNearQuery;
import org.apache.lucene.search.spans.SpanOrQuery;
import org.apache.lucene.search.spans.SpanQuery;
import org.apache.lucene.search.spans.SpanRangeQuery;
import org.apache.lucene.search.spans.SpanTermQuery;
import org.apache.lucene.search.spans.SpanWildcardQuery;
import org.cdlib.xtf.util.EasyNode;
import org.cdlib.xtf.util.GeneralException;
import org.cdlib.xtf.util.Path;
import org.cdlib.xtf.util.Trace;
import org.cdlib.xtf.util.XMLWriter;

/*
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

/**
 * Processes URL parameters into a Lucene query, using a stylesheet to perform
 * the heavy lifting.
 * 
 * @author Martin Haye
 */
public class QueryRequestParser 
{
    /** Partially parsed request in progress */
    private QueryRequest req;
    
    /** 
     * Keeps track of the servlet base directory, used to map relative
     * file paths.
     */
    private File        baseDir;
    
    /** 
     * Configuration object used when building trees (only created if
     * necessary.)
     */
    private Configuration config;
    
    /** The top-level source node */
    private NodeInfo topNode;
    
    /** Global attributes that were actually specified in the query */
    private HashSet specifiedGlobalAttrs = new HashSet();
    
    /** Accumulated list of grouping specifications */
    private Vector groupSpecs = new Vector(); 
    
    /** Default value for maxSnippets, so we can recognize difference between
     *  the default and a user-specified value.
     */
    private static final int DEFAULT_MAX_SNIPPETS = 888888888; 
    
    /**
     * Produce a Lucene query from the intermediate format that is normally
     * produced by the formatting stylesheet. Includes setting a default
     * indexPath, so the query doesn't have to contain one internally.
     * 
     * @param queryDoc A document containing the query.
     */
    public QueryRequest parseRequest( Source queryDoc,
                                      File   baseDir,
                                      String defaultIndexPath )
        throws QueryGenException, QueryFormatError
    {
        // Make a new request to start filling in.
        req = new QueryRequest();
        
        // Record the parameters
        this.baseDir = baseDir;
        req.indexPath = defaultIndexPath;
        
        // Output useful debug info
        if( Trace.getOutputLevel() >= Trace.debug ) {
            Trace.debug( "*** query request ***" );
            Trace.debug( XMLWriter.toString(queryDoc) );
        }

        // Now parse it, according to the kind of Source.
        if( queryDoc instanceof NodeInfo )
            parseOutputTop( new EasyNode((NodeInfo)queryDoc) );
        else {
            if( config == null )
                config = new Configuration();
            try {
                NodeInfo top = TreeBuilder.build( queryDoc, null, config );
                parseOutputTop( new EasyNode(top) );
            }
            catch( XPathException e ) {
                throw new RuntimeException( e );
            }
        }
        
        // Convert the grouping specifications to an easy-to-use array.
        if( groupSpecs.size() > 0 ) {
            req.groupSpecs = (GroupSpec[]) 
                groupSpecs.toArray( new GroupSpec[groupSpecs.size()] );
        }
        
        // And we're done.
        return req;
    } // parseRequest
    
    
    /**
     * Produce a Lucene query from the intermediate format that is normally
     * produced by the formatting stylesheet.
     * 
     * @param queryDoc A document containing the query.
     */
    public QueryRequest parseRequest( Source queryDoc,
                                      File   baseDir )
        throws QueryGenException, QueryFormatError
    {
        return parseRequest( queryDoc, baseDir, null );
    } // constructor
    
    
    /** Get an XML source suitable for re-creating this query */
    public Source getSource()
    {
        return topNode;
    } // getSource()
    
    
    /** Get the base directory from which relative paths are resolved */
    public File getBaseDir()
    {
        return baseDir;
    } // getBaseDir()
    
    
    /**
     * Convenience function to throw a {@link QueryGenException} with the 
     * given message.
     */
    private void error( String message )
        throws QueryGenException
    {
        throw new QueryGenException( message );
    } // error()
    
    
    /**
     * Processes the output of the generator stylesheet, turning it into a
     * Lucene query.
     * 
     * @param output The stylesheet output, whose first (and only) child
     *               should be a 'query' element.
     * @return The resulting Lucene query
     */
    private void parseOutputTop( EasyNode output )
        throws QueryGenException, QueryFormatError
    {
        if( "query".equals(output.name()) || "error".equals(output.name()) ) {
            parseOutput( output );
            return;
        }
        
        topNode = output.getWrappedNode();
        
        for( int i = 0; i < output.nChildren(); i++ ) {
            EasyNode main = output.child( i );
            String   name = main.name();
            
            if( !name.equals("query") && !name.equals("error") )
                error( "Expected 'query' or 'error' element at " +
                       "top level; found '" + name + "'" );
            
            parseOutput( main );
        }
    } // parseOutput()
    
    /**
     * Processes the main query node, turning it into a Lucene query.
     * 
     * @param main The 'query' element
     */
    private void parseOutput( EasyNode main )
    {
        if( main.name().equals("error") )
            throw new QueryFormatError( main.attrValue("message") );
        
        // Process all the top-level attributes.
        for( int i = 0; i < main.nAttrs(); i++ ) {
            String name = main.attrName( i );
            String val  = main.attrValue( i );
            parseMainAttrib( main, name, val );
        }

        // Process the children. If we find an old <combine> element,
        // traverse it just like a top-level query.
        //
        int nChildQueries = 0;
        for( int i = 0; i < main.nChildren(); i++ ) {
            EasyNode el = main.child( i );
            if( "groupField".equals(el.name()) )
                parseGroupSpec( el );
            else {
                req.query = 
                    deChunk( parseQuery(el, null, DEFAULT_MAX_SNIPPETS) );
                nChildQueries++;
            }
        }

        if( nChildQueries != 1 ) {
            error( "<" + main.name() + "> element must have " +
                   " exactly one child query" );
        }
        
        if( main.name().equals("query") &&
            Trace.getOutputLevel() >= Trace.debug )
        {
            Trace.debug( "Lucene query as parsed: " + req.query );
        }
        
        // Check that we got the required parameters.
        if( main.name().equals("query") ) {
            if( req.indexPath == null )
                error( "'indexPath' attribute missing from <query> element" );
        }
        
    } // parseOutput()
    
    
    /**
     * Parses a 'groupField' element and adds a GroupSpec to the query.
     * 
     * @param el  The 'groupField' element to parse
     */
    void parseGroupSpec( EasyNode el ) 
    {
        // Process all the attributes.
        GroupSpec gs = new GroupSpec();
        for( int i = 0; i < el.nAttrs(); i++ ) 
        {
            if( el.attrName(i).equalsIgnoreCase("field") )
                gs.field = el.attrValue( i );
            else if( el.attrName(i).equalsIgnoreCase("sortGroupsBy") ) {
                if( el.attrValue(i).matches("^count$|^value$") )
                    gs.sortGroupsBy = el.attrValue( i );
                else {
                    error( "Expected 'count' or 'value' for '" +
                           el.attrName(i) + "' attribute, but found '" +
                           el.attrValue(i) + "' (on '" + el.name() + 
                           " element)" );
                }
            }
            else
                error( "Unrecognized attribute '" + el.attrName(i) +
                       "' on '" + el.name() + "' element" );
        } // for i
        
        // Make sure a field name was specified.
        if( gs.field == null || gs.field.length() == 0 )
            error( "'" + el.name() + "' element requires 'field' attribute" );
        
        // Make sure there is only one groupField element per field.
        for( int i = 0; i < groupSpecs.size(); i++ ) {
            GroupSpec other = ((GroupSpec)groupSpecs.elementAt(i));
            if( other.field.equalsIgnoreCase(gs.field) )
                error( "Specifying two '" + el.name() + "' elements for the " +
                       "same field is illegal" );
        }
        
        // Check for subsets below the <groupField> node.
        Vector subsets = new Vector();
        for( int i = 0; i < el.nChildren(); i++ )
        {
            // Get the child, and check the name.
            EasyNode child = el.child( i );
            boolean countOnly = false;
            if( child.name().equalsIgnoreCase("countGroups") )
                countOnly = true;
            else if( child.name().equalsIgnoreCase("groupHits") )
                countOnly = false;
            else
                error( "Unrecognized child element '" + child.name() +
                       "' under '" + el.name() + "' element." );
            
            // Process the attributes.
            GroupSpec.Subset subset = new GroupSpec.Subset();
            boolean gotValue     = false;
            boolean gotMaxGroups = false;
            boolean gotMaxDocs   = false;
            for( int j = 0; j < child.nAttrs(); j++ ) 
            {
                String attrName = child.attrName( j );
                String attrVal  = child.attrValue( j );
                if( attrName.equalsIgnoreCase("startGroup") )
                    subset.startGroup = parseIntAttrib(child, attrName) - 1;
                else if( attrName.equalsIgnoreCase("maxGroups") ) {
                    subset.maxGroups = parseIntAttrib(child, attrName);
                    gotMaxGroups = true;
                }
                else if( attrName.equalsIgnoreCase("value") ) {
                    gotValue = true;
                    subset.value = attrVal;
                }
                else if( attrName.equalsIgnoreCase("startDoc") && !countOnly) {
                    if( countOnly )
                    subset.startDoc = parseIntAttrib(child, attrName) - 1;
                    if( subset.startDoc < 0 )
                        error( "'" + attrName + "' attribute on '" +
                               child.name() + "' element must be >= 1" );
                }
                else if( attrName.equalsIgnoreCase("maxDocs") && !countOnly ) {
                    subset.maxDocs = parseIntAttrib( child, attrName );
                    gotMaxDocs = true;
                }
                else if( attrName.equalsIgnoreCase("sortDocsBy") && !countOnly )
                    subset.sortDocsBy = attrVal;
                else
                    error( "Unrecognized attribute '" + attrName + "' on '" +
                           child.name() + "' element" );
            } // for j
            
            // 'value' is mutually exclusive with 'startGroup'/'maxGroups'
            if( gotValue && gotMaxGroups )
                error( "It doesn't make sense to specify both 'value' and " +
                       "'startGroup/maxGroups' on '" + child.name() + "element" );
            
            // If neither was specified, default to maxGroups=all
            if( !gotValue && !gotMaxGroups )
                subset.maxGroups = 999999999;
            
            // If maxDocs wasn't specified on <groupHits>, default to 10.
            if( !countOnly && !gotMaxDocs )
                subset.maxDocs = 10;
            
            // Add this subset to our list.
            subsets.add( subset );
        } // for i
        
        // Finally, add the new group spec to the query.
        groupSpecs.add( gs );
        
    } // parseGroupSpec
    
    
    /**
     * Recursively parse a query.
     */
    private Query parseQuery( EasyNode parent, String field, int maxSnippets )
       throws QueryGenException
    {
        String name = parent.name();
        if( !name.matches(
                "^query$|^term$|^all$|^range$|^phrase$|^near$" +
                "|^and$|^or$|^not$" +
                "|^combine$|^meta$|^text$") ) // old stuff, for compatability
        {
            error( "Expected: 'query', 'term', 'all', 'range', 'phrase', " +
                   "'near', 'and', 'or', or 'not'; found '" + name + "'" );
        }
        
        // Old stuff, for compatability.
        if( name.equals("text") )
            field = "text";
        else
            field = parseField( parent, field );

        // 'not' queries are handled at the level above.
        assert( !name.equals("not") );
        
        // Default to no boost.
        float boost = 1.0f;
        
        // Validate all attributes.
        for( int i = 0; i < parent.nAttrs(); i++ ) {
            String attrName = parent.attrName( i );
            String attrVal  = parent.attrValue( i );
            
            if( attrName.equals("boost") ) {
                try {
                    boost = Float.parseFloat( attrVal );
                }
                catch( NumberFormatException e ) {
                    error( "Invalid float value \"" + attrVal + "\" for " +
                           "'boost' attribute" );
                }
                if( boost < 0.0 )
                    error( "Value of 'boost' attribute cannot be negative" );
            }
            else if( attrName.equals("maxSnippets") ) {
                int oldVal = maxSnippets;
                maxSnippets = parseIntAttrib( parent, attrName );
                if( maxSnippets < 0 )
                    maxSnippets = 999999999;
                if( oldVal != DEFAULT_MAX_SNIPPETS &&
                    maxSnippets != oldVal )
                {
                    error( "Value specified for 'maxSnippets' attribute " +
                           "differs from that of an ancestor element." );
                }
            }
            else
                parseMainAttrib( parent, attrName, attrVal );
        }
        
        // Do the bulk of the parsing below...
        Query result = parseQuery2( parent, name, field, maxSnippets );
        
        // And set any boost that was specified.
        if( boost != 1.0f )
            result.setBoost( boost );
        
        // If a sectionType query was specified, add that to the mix.
        SpanQuery secType = parseSectionType( parent, field, maxSnippets );
        if( secType != null ) {
            SpanQuery combo = 
                 new SpanSectionTypeQuery( (SpanQuery)result, secType );
            combo.setSpanRecording( ((SpanQuery)result).getSpanRecording() );
            result = combo;
        }
        
        // All done!
        return result;
        
    } // parseQuery()
   
    
    /** 
     * Main work of recursively parsing a query. 
     */
    private Query parseQuery2( EasyNode parent, String name, String field,
                               int maxSnippets )
        throws QueryGenException
    {
        // Term query is the simplest kind.
        if( name.equals("term") ) {
            Term term = parseTerm( parent, field, "term" );
            SpanQuery q = isWildcardTerm(term) ? 
                new SpanWildcardQuery( term, req.termLimit ) :
                new SpanTermQuery( term );
            q.setSpanRecording( maxSnippets );
            return q;
        }
        
        // Get field name if specified.
        field = parseField( parent, field );
        
        // Range queries are also pretty simple.
        if( name.equals("range") )
            return parseRange( parent, field, maxSnippets );

        // For text queries, 'all', 'phrase', and 'near' can be viewed
        // as phrase queries with different slop values.
        //
        // 'all' means essentially infinite slop (limited to the actual
        //          chunk overlap at runtime.)
        // 'phrase' means zero slop
        // 'near' allows specifying the slop (again limited to the actual
        //          chunk overlap at runtime.)
        //
        if( name.equals("all") || name.equals("phrase") || name.equals("near"))
        {   
            int slop = name.equals("all") ? 999999999 :
                       name.equals("phrase") ? 0 :
                       parseIntAttrib( parent, "slop" );
            return makeProxQuery( parent, slop, field, maxSnippets );
        }
        
        // All other cases fall through to here: and, or. Use our special
        // de-duplicating span logic. First, get all the sub-queries.
        //
        Vector subVec = new Vector();
        Vector notVec = new Vector();
        for( int i = 0; i < parent.nChildren(); i++ ) {
            EasyNode el = parent.child( i );
            if( el.name().equals("sectionType") )
                ; // handled elsewhere
            else if( el.name().equals("not") ) { 
                Query q = parseQuery2(el, name, field, maxSnippets);
                if( q != null )
                    notVec.add( q );
            }
            else {
                Query q = parseQuery(el, field, maxSnippets);
                if( q != null )
                    subVec.add( q );
            }
        }
        
        // If no sub-queries, return an empty query.
        if( subVec.isEmpty() )
            return null;
        
        // If only one sub-query, just return that.
        if( subVec.size() == 1 && notVec.isEmpty() )
            return (Query) subVec.get(0);
        
        // Divide up the queries by field name.
        HashMap fieldQueries = new HashMap();
        for( int i = 0; i < subVec.size(); i++ ) {
            Query q = (Query) subVec.get(i);
            field = (q instanceof SpanQuery) ? 
                         ((SpanQuery)q).getField() : "<none>";
            if( !fieldQueries.containsKey(field) )
                fieldQueries.put( field, new Vector() );
            ((Vector)fieldQueries.get(field)).add( q );
        } // for i
        
        // Same with the "not" queries.
        HashMap fieldNots = new HashMap();
        for( int i = 0; i < notVec.size(); i++ ) {
            Query q = (Query) notVec.get(i);
            field = (q instanceof SpanQuery) ? 
                         ((SpanQuery)q).getField() : "<none>";
            if( !fieldNots.containsKey(field) )
                fieldNots.put( field, new Vector() );
            ((Vector)fieldNots.get(field)).add( q );
        } // for i
        
        // If we have only queries for the same field, our work is simple.
        if( fieldQueries.size() == 1 ) {
            Vector queries = (Vector) fieldQueries.values().iterator().next();
            Vector nots;
            if( fieldNots.isEmpty() )
                nots = new Vector();
            else {
                assert fieldNots.size() == 1 : "case not handled";
                nots = (Vector) fieldNots.values().iterator().next();
                assert nots.get(0) instanceof SpanQuery : "case not handled";
                String notField = ((SpanQuery)nots.get(0)).getField();
                String mainField = ((SpanQuery)queries.get(0)).getField();
                assert notField.equals(mainField) : "case not handled";
            }
            return processSpanJoin(name, queries, nots, maxSnippets);
        }
        
        // Now form a BooleanQuery containing grouped span queries where
        // appropriate.
        //
        BooleanQuery bq = new BooleanQuery();
        boolean require = !name.equals("or");
        TreeSet keySet = new TreeSet( fieldQueries.keySet() );
        for( Iterator i = keySet.iterator(); i.hasNext(); ) {
            field = (String) i.next();
            Vector queries = (Vector) fieldQueries.get( field );
            Vector nots = (Vector) fieldNots.get( field );
            if( nots == null )
                nots = new Vector();

            if( field.equals("<none>") ||
                (queries.size() == 1 && nots.isEmpty()) )
            {
                for( int j = 0; j < queries.size(); j++ )
                    bq.add( deChunk((Query)queries.get(j)), require, false );
                for( int j = 0; j < nots.size(); j++ )
                    bq.add( deChunk((Query)queries.get(j)), false, true );
                continue;
            }

            // Span query/queries. Join them into a single span query.
            SpanQuery sq = processSpanJoin(name, queries, nots, maxSnippets);   
            bq.add( deChunk(sq), require, false );
        } // for i
        
        // Simplify the BooleanQuery (if possible), for instance collapsing
        // an AND query inside another AND query.
        //
        return simplifyBooleanQuery( bq );
        
    } // parseQuery2() 
        
        
    /**
     * Simplify a BooleanQuery that contains other BooleanQuery/ies with the
     * same type of clauses. If there's any boosting involved, don't do
     * the optimization.
     */
    private Query simplifyBooleanQuery( BooleanQuery bq )
    {
        boolean anyBoosting = false;
        boolean anyBoolSubs = false;
        boolean allSame = true;
        boolean first = true;
        boolean prevRequired = true;
        boolean prevProhibited = true;
        
        // Scan each clause.
        BooleanClause[] clauses = bq.getClauses();
        for( int i = 0; i < clauses.length; i++ ) 
        {
            // See if this clause is the same as the previous one.
            if( !first && 
                (prevRequired   != clauses[i].required ||
                 prevProhibited != clauses[i].prohibited ) )
                allSame = false;
            
            prevRequired   = clauses[i].required;
            prevProhibited = clauses[i].prohibited;
            first = false;
          
            // Detect any boosting
            if( clauses[i].query.getBoost() != 1.0f )
                anyBoosting = true;
            
            // If the clause is a BooleanQuery, check the sub-clauses...
            if( clauses[i].query instanceof BooleanQuery ) 
            {
                BooleanQuery    subQuery = (BooleanQuery) clauses[i].query;
                BooleanClause[] subClauses = subQuery.getClauses();
                
                // Scan each sub-clause
                for( int j = 0; j < subClauses.length; j++ ) 
                {
                    // Make sure it's the same as the previous clause.
                    if( prevRequired   != subClauses[j].required ||
                        prevProhibited != subClauses[j].prohibited )
                        allSame = false;
                    
                    prevRequired = subClauses[j].required;
                    prevProhibited = subClauses[j].prohibited;
                    
                    // Detect any boosting.
                    if( subClauses[j].query.getBoost() != 1.0f )
                        anyBoosting = true;
                } // for j
                
                // Note that we found at least one BooleanQuery clause.
                anyBoolSubs = true;
            }
        } // for i
        
        // If the main BooleanQuery doesn't meet all of our criteria for
        // simplification, simply return it unmodified.
        //
        if( !anyBoolSubs || !allSame || anyBoosting )
            return bq;
        
        // Create a new, simplified, query.
        bq = new BooleanQuery();
        for( int i = 0; i < clauses.length; i++ ) {
            if( clauses[i].query instanceof BooleanQuery ) {
                BooleanQuery    subQuery = (BooleanQuery) clauses[i].query;
                BooleanClause[] subClauses = subQuery.getClauses();
                for( int j = 0; j < subClauses.length; j++ )
                    bq.add( subClauses[j] );
            }
            else
                bq.add( clauses[i] );
        }

        // And we're done.
        return bq;
        
    } // simplifyBooleanQuery()
        
    
    /**
     * Parse an attribute on the main query element (or, for backward
     * compatability, on its immediate children.)
     * 
     * If the attribute isn't recognized, an error exception is thrown.
     */
    void parseMainAttrib( EasyNode el, String attrName, String val )
    {
        if( attrName.equals("style") )
            req.displayStyle = onceOnlyPath( req.displayStyle, el, attrName );

        else if( attrName.equals("startDoc") ) {
            req.startDoc = onceOnlyAttrib( req.startDoc+1, el, attrName );
            
            // Adjust for 1-based start doc.
            req.startDoc = Math.max( 0, req.startDoc-1 );
        }
        
        else if( attrName.equals("maxDocs") )
            req.maxDocs = onceOnlyAttrib( req.maxDocs, el, attrName );
        
        else if( attrName.equals("indexPath") )
            req.indexPath = onceOnlyPath( req.indexPath, el, attrName );
        
        else if( attrName.equals("termLimit") )
            req.termLimit = onceOnlyAttrib( req.termLimit, el, attrName );
        
        else if( attrName.equals("workLimit") )
            req.workLimit = onceOnlyAttrib( req.workLimit, el, attrName );
        
        else if( attrName.equals("sortDocsBy") ||
                 attrName.equals("sortMetaFields") ) // old, for compatibility
            req.sortMetaFields = onceOnlyAttrib( req.sortMetaFields, el, attrName );
        
        else if( attrName.equals("maxContext") || attrName.equals("contextChars") )
            req.maxContext = onceOnlyAttrib( req.maxContext, el, attrName );
        
        else if( attrName.equals("termMode") ) {
            int oldTermMode = req.termMode;
            if( val.equalsIgnoreCase("none") )
                req.termMode = SpanDocument.MARK_NO_TERMS;
            else if( val.equalsIgnoreCase("hits") )
                req.termMode = SpanDocument.MARK_SPAN_TERMS;
            else if( val.equalsIgnoreCase("context") )
                req.termMode = SpanDocument.MARK_CONTEXT_TERMS;
            else if( val.equalsIgnoreCase("all") )
                req.termMode = SpanDocument.MARK_ALL_TERMS;
            else
                error( "Unknown value for 'termMode'; expecting " +
                       "'none', 'hits', 'context', or 'all'" );
            
            if( specifiedGlobalAttrs.contains(attrName) && 
                req.termMode != oldTermMode )
            {
                error( "'termMode' attribute should only be specified once." );
            }
            specifiedGlobalAttrs.add( attrName );
        }
        
        else if( attrName.equals("field") || attrName.equals("metaField") )
            ; // handled elsewhere
        
        else if( attrName.equals("inclusive") &&
                 el.name().equals("range") )
            ; // handled elsewhere
        
        else if( attrName.equals("slop") &&
                 el.name().equals("near") )
            ; // handled elsewhere
        
        else {
            error( "Unrecognized attribute \"" + attrName + "\" " +
                   "on <" + el.name() + "> element" );
        }
    } // parseMainAttrib()
    
    
    /**
     * Parse a 'sectionType' query element, if one is present. If not, 
     * simply returns null.
     */
    private SpanQuery parseSectionType( EasyNode parent, 
                                        String field,
                                        int maxSnippets )
        throws QueryGenException
    {
        // Find the sectionType element (if any)
        EasyNode sectionType = parent.child( "sectionType" );
        if( sectionType == null )
            return null;
        
        // These sectionType queries only belong in the "text" field.
        if( !(field.equals("text")) )
            error( "'sectionType' element is only appropriate in queries on the 'text' field" );
        
        // Make sure it only has one child.
        if( sectionType.nChildren() != 1 )
            error( "'sectionType' element requires exactly " +
                   "one child element" );
        
        return (SpanQuery) parseQuery( sectionType.child(0), 
                                       "sectionType", maxSnippets );
    } // parseSectionType()

    
    /**
     * If the given element has a 'field' attribute, return its value;
     * otherwise return 'parentField'. Also checks that field cannot be
     * specified if parentField has already been.
     */
    private String parseField( EasyNode el, String parentField )
        throws QueryGenException
    {
        if( !el.hasAttr("metaField") && !el.hasAttr("field") )
            return parentField;
        String attVal = el.attrValue("field");
        if( attVal == null || attVal.length() == 0 )
            attVal = el.attrValue( "metaField" );
        
        if( attVal.length() == 0 )
            error( "'field' attribute cannot be empty" );
        if( attVal.equals("sectionType") &&
            (parentField == null || !parentField.equals("sectionType")) )
            error( "'sectionType' is not valid for the 'field' attribute" );
        if( parentField != null && !parentField.equals(attVal) )
            error( "Cannot override ancestor 'field' attribute" );
        
        return attVal;
    }

    
    /**
     * Joins a number of span queries together using a span query.
     * 
     * @param name    'and', 'or', 'near', etc.
     * @param subVec  Vector of sub-clauses
     * @param notVec  Vector of not clauses (may be empty)
     * 
     * @return        A new Span query joining the sub-clauses.
     */
    private SpanQuery processSpanJoin( String name, Vector subVec, 
                                       Vector notVec, int maxSnippets )
    {
        SpanQuery[] subQueries = 
            (SpanQuery[]) subVec.toArray( new SpanQuery[0] ); 
        
        // Now make the top-level query.
        SpanQuery q;
        if( subQueries.length == 1 )
            q = subQueries[0];
        else if( !name.equals("or") ) {
            // We can't know the actual slop until the query is run against
            // an index (the slop will be equal to max proximity). So set
            // it to a big value for now, and it will be clamped by
            // fixupSlop() later whent he query is run.
            //
            q = new SpanNearQuery( subQueries, 999999999, false );
        }
        else
            q = new SpanOrQuery( subQueries );

        q.setSpanRecording( maxSnippets );
        
        // Finish up by handling any not clauses found.
        return processTextNots( q, notVec, maxSnippets );
        
    } // processSpanJoin()

    /**
     * Ensures that the given query, if it is a span query on the "text"
     * field, is wrapped by a de-chunking query.
     */
    private Query deChunk( Query q )
    {
        // We only need to de-chunk span queries, not other queries.
        if( !(q instanceof SpanQuery) )
            return q;
        
        // Furthermore, we only need to de-chunk queries on the "text"
        // field.
        //
        SpanQuery sq = (SpanQuery) q;
        if( !sq.getField().equals("text") )
            return q;
        
        // If it's already de-chunked, no need to do it again.
        if( sq instanceof SpanDechunkingQuery )
            return q;
        
        // Okay, wrap it.
        SpanDechunkingQuery dq = new SpanDechunkingQuery( sq );
        dq.setSpanRecording( sq.getSpanRecording() );
        return dq;
        
    } // deChunk()  
      
    /** Determines if the term contains a wildcard character ('*' or '?') */
    private boolean isWildcardTerm( Term term )
    {
        if( term.text().indexOf('*') >= 0 )
            return true;
        if( term.text().indexOf('?') >= 0 )
            return true;
        return false;
    } // isWildcardTerm()

    /**
     * Parse a range query.
     */
    private Query parseRange( EasyNode parent, String field, int maxSnippets )
        throws QueryGenException
    {
        // Inclusive or exclusive?
        boolean inclusive = false;
        String yesno = parseStringAttrib( parent, "inclusive", "yes" );
        if( yesno.equals("yes") )
            inclusive = true;
        else if( !yesno.equals("no") )
            error( "'inclusive' attribute for 'range' query must have value " +
                   "'yes' or 'no'" );
        
        // Check the children for the lower and upper bounds.
        Term lower = null;
        Term upper = null;
        for( int i = 0; i < parent.nChildren(); i++ ) {
            EasyNode child = parent.child( i );
            String name = child.name();
            if( name.equals("lower") ) {
                if( lower != null )
                    error( "'lower' only allowed once as child of 'range' element" );
                if( child.child("term") != null )
                    lower = parseTerm( child.child("term"), field, "term" );
                else
                    lower = parseTerm( child, field, "lower" );
            }
            else if( name.equals("upper") ) {
                if( upper != null )
                    error( "'upper' only allowed once as child of 'range' element" );
                if( child.child("term") != null )
                    upper = parseTerm( child.child("term"), field, "term" );
                else
                    upper = parseTerm( child, field, "upper" );
            }
            else
                error( "'range' element may only have 'lower' and/or 'upper' " +
                       "as child elements" );
        } // for iter
        
        // Upper, lower, or both must be specified.
        if( lower == null && upper == null )
            error( "'range' element must have 'lower' and/or 'upper' child element(s)" );
        
        // And we're done.
        SpanQuery q = new SpanRangeQuery( lower, upper, inclusive, req.termLimit );
        q.setSpanRecording( maxSnippets );
        return q;
    } // parseRange()

    /**
     * If any 'not' clauses are present, this builds a query that filters them
     * out of the main query.
     */
    SpanQuery processTextNots( SpanQuery query, Vector notClauses,
                               int maxSnippets ) 
    {
        // If there aren't any 'not' clauses, we're done.
        if( notClauses.isEmpty() )
            return query;
        
        // If there's only one, the sub-query is simple.
        SpanQuery subQuery;
        if( notClauses.size() == 1 )
            subQuery = (SpanQuery) notClauses.get( 0 );
        else 
        {
            // Otherwise, 'or' all the nots together.
            SpanQuery[] subs = (SpanQuery[]) 
                notClauses.toArray( new SpanQuery[0] );
            subQuery = new SpanOrQuery( subs );
            subQuery.setSpanRecording( maxSnippets );
        }
        
        // Now make the final 'not' query. Note that the actual slop will have
        // to be fixed when the query is run.
        //
        SpanQuery nq = new SpanChunkedNotQuery( query, subQuery, 999999999 );
        nq.setSpanRecording( maxSnippets );
        return nq;
    } // processTextNots();
    
    
    /**
     * Generate a proximity query on a field. This uses the de-duplicating span
     * system.
     * 
     * @param parent The element containing the field name and terms.
     */
    Query makeProxQuery( EasyNode parent, int slop, String field,
                         int maxSnippets )
        throws QueryGenException
    {
        Vector terms  = new Vector();
        Vector notVec = new Vector();
        for( int i = 0; i < parent.nChildren(); i++ ) {
            EasyNode el = parent.child( i );
            if( el.name().equals("not") ) {
                if( slop == 0 )
                    error( "'not' clauses aren't supported in phrase queries" );
                
                // Make sure to avoid adding the 'not' terms to the term map,
                // since it would be silly to hilight them.
                //
                notVec.add( parseQuery(el, field, maxSnippets) );
            }
            else {
                SpanQuery q;
                if( slop == 0 ) {
                    Term t = parseTerm( el, field, "term" );
                    if( isWildcardTerm(t) )
                        q = new SpanWildcardQuery(t, req.termLimit);
                    else
                        q = new SpanTermQuery(t);
                    q.setSpanRecording( maxSnippets );
                    terms.add( q );
                }
                else
                    terms.add( parseQuery(el, field, maxSnippets) );
            }
        }
        
        if( terms.size() == 0 )
            error( "'" + parent.name() + "' element requires at " +
                   "least one term" );
        
        // Optimization: treat a single-term 'all' query as just a simple
        // term query.
        //
        if( terms.size() == 1 )
            return (SpanQuery) terms.elementAt(0);
        
        // Make a 'near' query out of it. Zero slop implies in-order.
        boolean inOrder = (slop == 0);
        SpanQuery q = new SpanNearQuery( 
                                  (SpanQuery[]) terms.toArray(new SpanQuery[0]), 
                                  slop,
                                  inOrder );
        q.setSpanRecording( maxSnippets );
        
        // And we're done.
        return q;
        
    } // makeTextAllQuery()
    
    
    /**
     * Parses a 'term' element. If not so marked, an exception is thrown.
     * 
     * @param parent The element to parse
     */
    private Term parseTerm( EasyNode parent, String field, String expectedName )
        throws QueryGenException
    {
        // Get field name if specified.
        field = parseField( parent, field );
        if( field == null )
            error( "'term' element requires 'field' attribute on " +
                   "itself or an ancestor" );
        
        if( !parent.name().equals(expectedName) )
            error( "Expected '" + expectedName + "' as child of '" + 
                   parent.parent().name() +
                   "' element, but found '" + parent.name() + "'" );
        
        String termText  = getText( parent );
        if( termText == null || termText.length() == 0 )
            error( "Missing term text in element '" + parent.name() + "'" );
        
        // For now, convert text to lowercase. In the future, we might allow
        // case-sensitive searching.
        //
        termText = termText.toLowerCase();
        
        // Make a term out of the field and the text.
        Term term = new Term( field, termText );
        
        return term;
        
    } // parseTerm()
    
    /**
     * Ensures that the element has only a single child node (ignoring
     * attributes), and that it's a text node.
     * 
     * @param el The element to get the text of
     * @return The string value of the text
     */
    private String getText( EasyNode el )
        throws QueryGenException
    {
        // There should be no element children, only text.
        int count = 0;
        String text = null;
        for( int i = 0; i < el.nChildren(); i++ ) {
            EasyNode n = el.child(i);
            if( !n.isElement() && !n.isText() )
            {
                count = -1;
                break;
            }
            if( n.isText() )
                text = n.toString();
            count++;
        }
        
        if( count != 1 )
            error( "A single text node is required for the '" +
                   el.name() + "' element" );
        
        return text;
    } // getText()
    
    /**
     * Like parseIntAttrib(), but adds additional processing to ensure that
     * global parameters are only specified once (or if multiple times, that
     * the same value is used each time.)
     * 
     * @param oldVal      Current value of the global parameter
     * @param el          Element to get the attribute from
     * @param attribName  Name of the attribute
     * @return            New value for the parameter
     */
    private int onceOnlyAttrib( int oldVal, EasyNode el, String attribName )
    {
        int newVal = parseIntAttrib( el, attribName );
        if( specifiedGlobalAttrs.contains(attribName) && newVal != oldVal ) {
            error( "'" + attribName + 
                   "' attribute should only be specified once." );
        }
        specifiedGlobalAttrs.add( attribName );
        return newVal;
    } // onceOnlyAttrib()

    /**
     * Like parseStringAttrib(), but adds additional processing to ensure that
     * global parameters are only specified once (or if multiple times, that
     * the same value is used each time.)
     * 
     * @param oldVal      Current value of the global parameter
     * @param el          Element to get the attribute from
     * @param attribName  Name of the attribute
     * @return            New value for the parameter
     */
    private String onceOnlyAttrib( String oldVal, 
                                   EasyNode el, 
                                   String attribName )
    {
        String newVal = parseStringAttrib( el, attribName );
        if( specifiedGlobalAttrs.contains(attribName) && 
            !oldVal.equals(newVal) )
        {
            error( "'" + attribName + 
                   "' attribute should only be specified once." );
        }
        specifiedGlobalAttrs.add( attribName );
        return newVal;
    } // onceOnlyAttrib()

    /**
     * Like onceOnlyAttrib(), but also ensures that the given file can
     * actually be resolved as a path that can be read.
     * 
     * @param oldVal      Current value of the global parameter
     * @param el          Element to get the attribute from
     * @param attribName  Name of the attribute
     * @return            New value for the parameter
     */
    private String onceOnlyPath( String oldVal, 
                                 EasyNode el, 
                                 String attribName )
    {
        String newVal = parseStringAttrib( el, attribName );
        String path = Path.resolveRelOrAbs( baseDir, newVal );
        if( specifiedGlobalAttrs.contains(attribName) && 
            !oldVal.equals(path) )
        {
            error( "'" + attribName + 
                   "' attribute should only be specified once." );
        }
        specifiedGlobalAttrs.add( attribName );

        if( !(new File(path).canRead()) &&
            !newVal.equals("NullStyle.xsl") ) 
        {
            error( "File \"" + newVal + "\" specified in '" + 
                   el.name() + "' element " + "does not exist" );
        }
        
        return path;
    } // onceOnlyPath()

    /**
     * Locate the named attribute and retrieve its value as an integer.
     * If not found, an error exception is thrown.
     * 
     * @param el Element to search
     * @param attribName Attribute to find
     */
    private int parseIntAttrib( EasyNode el, String attribName )
        throws QueryGenException
    {
        return parseIntAttrib( el, attribName, false, 0 );
    }
    
    /**
     * Locate the named attribute and retrieve its value as an integer.
     * If not found, return a default value.
     * 
     * @param el EasyNode to search
     * @param attribName Attribute to find
     * @param defaultVal If not found and useDefault is true, return this 
     *                   value.
     */
    private int parseIntAttrib( EasyNode el, 
                                String attribName, 
                                int defaultVal  )
        throws QueryGenException
    {
        return parseIntAttrib( el, attribName, true, defaultVal );
    }
    
    /**
     * Locate the named attribute and retrieve its value as an integer.
     * Handles default processing if requested.
     * 
     * @param el EasyNode to search
     * @param attribName Attribute to find
     * @param useDefault true to supply a default value if none found,
     *                   false to throw an exception if not found.
     * @param defaultVal If not found and useDefault is true, return this 
     *                   value.
     */
    private int parseIntAttrib( EasyNode el, String attribName, 
                                boolean useDefault, int defaultVal )
        throws QueryGenException
    {
        String elName = el.name();
        String str = parseStringAttrib( el, 
                                        attribName,
                                        useDefault,
                                        null );
        if( str == null && useDefault )
            return defaultVal;
        
        if( str.equals("all") )
            return 999999999;
        
        try {
            return Integer.parseInt( str );
        } catch( Exception e ) {
            error( "'" + attribName + "' attribute of '" + elName + 
                   "' element is not a valid integer" );
            return 0;
        }
    } // parseIntAttrib()
    
    
    /**
     * Locate the named attribute and retrieve its value as a string. If
     * not found, an error exception is thrown.
     * 
     * @param el EasyNode to search
     * @param attribName Attribute to find
     */
    private String parseStringAttrib( EasyNode el, 
                                      String  attribName ) 
        throws QueryGenException
    {
        return parseStringAttrib( el, attribName, false, null );
    }
    
    /**
     * Locate the named attribute and retrieve its value as a string. If
     * not found, return a default value.
     * 
     * @param el EasyNode to search
     * @param attribName Attribute to find
     * @param defaultVal If not found, return this value.
     */
    private String parseStringAttrib( EasyNode el, 
                                      String  attribName,
                                      String  defaultVal ) 
        throws QueryGenException
    {
        return parseStringAttrib( el, attribName, true, defaultVal );
    }
    
    /**
     * Locate the named attribute and retrieve its value as a string.
     * Handles default processing if requested.
     * 
     * @param el EasyNode to search
     * @param attribName Attribute to find
     * @param useDefault true to supply a default value if none found,
     *                   false to throw an exception if not found.
     * @param defaultVal If not found and useDefault is true, return this 
     *                   value.
     */
    private String parseStringAttrib( EasyNode el, 
                                      String  attribName, 
                                      boolean useDefault,
                                      String  defaultVal )
        throws QueryGenException
    {
        String elName = el.name();
        String str = el.attrValue( attribName );

        if( str == null || str.length() == 0 ) {
            if( !useDefault )
                error( "'" + elName + "' element must specify '" + 
                       attribName + "' attribute" );
            return defaultVal;
        }
        
        return str;
        
    } // parseStringAttrib()
    
    
    /**
     * Exception class used to report errors from the query generator.
     */
    public class QueryFormatError extends GeneralException
    {
        public QueryFormatError( String message ) {
            super( message );
        }
        
        public boolean isSevere() { return false; }
    } // class QueryFormatError
    
}
