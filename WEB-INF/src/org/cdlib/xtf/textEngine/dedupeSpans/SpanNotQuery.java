package org.cdlib.xtf.textEngine.dedupeSpans;

/**
 * Copyright 2004 The Apache Software Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import java.io.IOException;

import java.util.Collection;

import org.apache.lucene.index.IndexReader;
import org.apache.lucene.search.Searcher;

/** 
 * Removes matches which overlap with another SpanQuery. 
 * 
 * MCH: Added 'slop' factor; if positive, matches will be forced to have at
 *      least this much space between them. If negative, they'll be allowed
 *      to overlap by the given amount.
 */
public class SpanNotQuery extends SpanQuery {
  private SpanQuery include;
  private SpanQuery exclude;
  private int       slop;
  private int       chunkBump;

  /** Construct a SpanNotQuery matching spans from <code>include</code> which
   * have no overlap with spans from <code>exclude</code>.*/
  public SpanNotQuery(SpanQuery include, SpanQuery exclude, int slop) {
    this.include = include;
    this.exclude = exclude;
    this.slop    = slop;

    if (!include.getField().equals(exclude.getField()))
      throw new IllegalArgumentException("Clauses must have same field.");
  }

  /** Return the SpanQuery whose matches are filtered. */
  public SpanQuery getInclude() { return include; }

  /** Return the SpanQuery whose matches must not overlap those returned. */
  public SpanQuery getExclude() { return exclude; }
  
  /** Set the distance that must separate matches from excluded spans.*/
  public void setSlop( int slop, int chunkBump ) { 
      this.slop = slop;
      this.chunkBump = chunkBump;
  }

  /** Return the distance that must separate matches from excluded spans.*/
  public int getSlop() {
      return slop;
  }

  public String getField() { return include.getField(); }

  public Collection getTerms() { return include.getTerms(); }

  public void calcCoordBits( TermMaskSet maskSet ) {
    include.calcCoordBits( maskSet );
  }

  public String toString(String field) {
    StringBuffer buffer = new StringBuffer();
    buffer.append("spanNot(");
    buffer.append(include.toString(field));
    buffer.append(", ");
    buffer.append(exclude.toString(field));
    buffer.append(")");
    return buffer.toString();
  }


  public Spans getSpans(final IndexReader reader, final Searcher searcher) 
      throws IOException 
  {
    return new Spans() {
        private Spans includeSpans = include.getSpans(reader, searcher);
        private boolean moreInclude = true;

        private Spans excludeSpans = exclude.getSpans(reader, searcher);
        private boolean moreExclude = true;
        private boolean firstTime = true;

        public boolean next() throws IOException {
          if (moreInclude)                        // move to next include
            moreInclude = includeSpans.next();
          if (firstTime) {
              moreExclude = excludeSpans.next();
              firstTime = false;
          }

          while (moreInclude && moreExclude) {

            int includeDoc = includeSpans.doc();
            if( includeSpans.start() < slop )
                includeDoc--;
            if (includeDoc > excludeSpans.doc()) // skip exclude
                  moreExclude = excludeSpans.skipTo(includeDoc);

            while (moreExclude                    // while exclude is before
                   && (endPos(excludeSpans)+slop) <= startPos(includeSpans)) {
              moreExclude = excludeSpans.next();  // increment exclude
            }

            if (!moreExclude                      // if no intersection
                || endPos(includeSpans) <= (startPos(excludeSpans)-slop))
              break;                              // we found a match

            moreInclude = includeSpans.next();    // intersected: keep scanning
          }
          return moreInclude;
        }
        
        private int baseDoc() {
            if( !moreInclude )
                return moreExclude ? excludeSpans.doc() : 0;
            if( !moreExclude )
                return includeSpans.doc();
            return Math.min(includeSpans.doc(), excludeSpans.doc());
        }
        
        private int startPos( Spans spans ) {
            return ((spans.doc() - baseDoc()) * chunkBump) + spans.start(); 
        }
        
        private int endPos( Spans spans ) {
            return ((spans.doc() - baseDoc()) * chunkBump) + spans.end(); 
        }
        
        private int posToDoc( int pos ) {
            return (pos / chunkBump) + baseDoc();
        }
        
        public boolean skipTo(int target) throws IOException {
          if (moreInclude)                        // skip include
            moreInclude = includeSpans.skipTo(target);

          if (!moreInclude)
            return false;

          if (moreExclude                         // skip exclude
              && includeSpans.doc() > excludeSpans.doc())
            moreExclude = excludeSpans.skipTo(includeSpans.doc());

          while (moreExclude                      // while exclude is before
                 && includeSpans.doc() == excludeSpans.doc()
                 && excludeSpans.end() <= (includeSpans.start()-slop)) {
            moreExclude = excludeSpans.next();    // increment exclude
          }

          if (!moreExclude                      // if no intersection
                || includeSpans.doc() != excludeSpans.doc()
                || (includeSpans.end()+slop) <= excludeSpans.start())
            return true;                          // we found a match

          return next();                          // scan to next match
        }

        public int doc() { return includeSpans.doc(); }
        public int start() { return includeSpans.start(); }
        public int end() { return includeSpans.end(); }
        public float score() { return includeSpans.score(); }
        public int coordBits() { return includeSpans.coordBits(); }
        public Collection allTerms() { return includeSpans.allTerms(); }

        public String toString() {
          return "spans(" + SpanNotQuery.this.toString() + ")";
        }

      };
  }

}
