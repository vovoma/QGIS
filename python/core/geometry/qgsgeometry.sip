
/** Polyline is represented as a vector of points */
typedef QVector<QgsPoint> QgsPolyline;

/** Polygon: first item of the list is outer ring, inner rings (if any) start from second item */
typedef QVector< QVector<QgsPoint> > QgsPolygon;

/** A collection of QgsPoints that share a common collection of attributes */
typedef QVector<QgsPoint> QgsMultiPoint;

/** A collection of QgsPolylines that share a common collection of attributes */
typedef QVector< QVector<QgsPoint> > QgsMultiPolyline;

/** A collection of QgsPolygons that share a common collection of attributes */
typedef QVector< QVector< QVector<QgsPoint> > > QgsMultiPolygon;

/** \ingroup core
 * A geometry is the spatial representation of a feature. Since QGIS 2.10, QgsGeometry acts as a generic container
 * for geometry objects. QgsGeometry is implicitly shared, so making copies of geometries is inexpensive. The geometry
 * container class can also be stored inside a QVariant object.
 *
 * The actual geometry representation is stored as a @link QgsAbstractGeometry @endlink within the container, and
 * can be accessed via the @link geometry @endlink method or set using the @link setGeometry @endlink method.
 */

class QgsGeometry
{
%TypeHeaderCode
#include <qgsgeometry.h>
%End

  public:
    //! Constructor
    QgsGeometry();

    /** Copy constructor will prompt a deep copy of the object */
    QgsGeometry( const QgsGeometry & );

    /** Creates a geometry from an abstract geometry object. Ownership of
     * geom is transferred.
     * @note added in QGIS 2.10
     */
    explicit QgsGeometry( QgsAbstractGeometry* geom /Transfer/ );

    //! Destructor
    ~QgsGeometry();

    /** Returns the underlying geometry store.
     * @note added in QGIS 2.10
     * @see setGeometry
     */
    QgsAbstractGeometry* geometry() const;

    /** Sets the underlying geometry store. Ownership of geometry is transferred.
     * @note added in QGIS 2.10
     * @see geometry
     */
    void setGeometry( QgsAbstractGeometry* geometry /Transfer/ );

    /** Returns true if the geometry is empty (ie, contains no underlying geometry
     * accessible via @link geometry @endlink).
     * @see geometry
     * @note added in QGIS 2.10
     */
    bool isEmpty() const;

    /** Creates a new geometry from a WKT string */
    static QgsGeometry fromWkt( const QString& wkt );
    /** Creates a new geometry from a QgsPoint object*/
    static QgsGeometry fromPoint( const QgsPoint& point );
    /** Creates a new geometry from a QgsMultiPoint object */
    static QgsGeometry fromMultiPoint( const QgsMultiPoint& multipoint );
    /** Creates a new geometry from a QgsPolyline object */
    static QgsGeometry fromPolyline( const QgsPolyline& polyline );
    /** Creates a new geometry from a QgsMultiPolyline object*/
    static QgsGeometry fromMultiPolyline( const QgsMultiPolyline& multiline );
    /** Creates a new geometry from a QgsPolygon */
    static QgsGeometry fromPolygon( const QgsPolygon& polygon );
    /** Creates a new geometry from a QgsMultiPolygon */
    static QgsGeometry fromMultiPolygon( const QgsMultiPolygon& multipoly );
    /** Creates a new geometry from a QgsRectangle */
    static QgsGeometry fromRect( const QgsRectangle& rect );
    /** Creates a new multipart geometry from a list of QgsGeometry objects*/
    static QgsGeometry collectGeometry( const QList< QgsGeometry >& geometries );

    /**
     * Set the geometry, feeding in a geometry in GEOS format.
     * This class will take ownership of the buffer.
     * @note not available in python bindings
     */
    // void fromGeos( GEOSGeometry* geos );

    /**
      Set the geometry, feeding in the buffer containing OGC Well-Known Binary and the buffer's length.
      This class will take ownership of the buffer.
     */
    void fromWkb( unsigned char * wkb /Array/, int length /ArraySize/ );
%MethodCode
  // create copy of Python's string and pass it to fromWkb()
  unsigned char * copy = new unsigned char[a1];
  memcpy(copy, a0, a1);
  sipCpp->fromWkb(copy, a1);
%End

    /**
       Returns the buffer containing this geometry in WKB format.
       You may wish to use in conjunction with wkbSize().
       @see wkbSize
     */
    SIP_PYOBJECT asWkb();
%MethodCode
  sipRes = PyBytes_FromStringAndSize((const char *)sipCpp->asWkb(), sipCpp->wkbSize());
%End

    /**
     * Returns the size of the WKB in asWkb().
     * @see asWkb
     */
    int wkbSize() const;

    /** Returns a geos geometry. QgsGeometry retains ownership of the geometry, so the returned object should not be deleted.
     *  @param precision The precision of the grid to which to snap the geometry vertices. If 0, no snapping is performed.
     *  @note this method was added in version 1.1
     *  @note not available in python bindings
     */
    // const GEOSGeometry* asGeos( double precision = 0 ) const;

    /** Returns type of the geometry as a WKB type (point / linestring / polygon etc.)
     * @see type
     */
    QgsWkbTypes::Type wkbType() const;

    /** Returns type of the geometry as a QgsWkbTypes::GeometryType
     * @see wkbType
     */
    QgsWkbTypes::GeometryType type() const;

    /** Returns true if WKB of the geometry is of WKBMulti* type */
    bool isMultipart() const;

    /** Compares the geometry with another geometry using GEOS
      @note added in 1.5
     */
    bool isGeosEqual( const QgsGeometry& ) const;

    /** Checks validity of the geometry using GEOS
      @note added in 1.5
     */
    bool isGeosValid() const;

    /** Check if the geometry is empty using GEOS
      @note added in 1.5
     */
    bool isGeosEmpty() const;

    /** Returns the area of the geometry using GEOS
      @note added in 1.5
     */
    double area() const;

    /** Returns the length of geometry using GEOS
      @note added in 1.5
     */
    double length() const;

    /**
     * Returns the minimum distance between this geometry and another geometry, using GEOS.
     * Will return a negative value if a geometry is missing.
     *
     * @param geom geometry to find minimum distance to
     */
    double distance( const QgsGeometry& geom ) const;

    /**
     * Returns the vertex closest to the given point, the corresponding vertex index, squared distance snap point / target point
     * and the indices of the vertices before and after the closest vertex.
     * @param point point to search for
     * @param atVertex will be set to the vertex index of the closest found vertex
     * @param beforeVertex will be set to the vertex index of the previous vertex from the closest one. Will be set to -1 if
     * not present.
     * @param afterVertex will be set to the vertex index of the next vertex after the closest one. Will be set to -1 if
     * not present.
     * @param sqrDist will be set to the square distance between the closest vertex and the specified point
     * @returns closest point in geometry
     */
    //TODO QGIS 3.0 - rename beforeVertex to previousVertex, afterVertex to nextVertex
    QgsPoint closestVertex( const QgsPoint& point, int& atVertex /Out/, int& beforeVertex /Out/, int& afterVertex /Out/, double& sqrDist /Out/ ) const;

    /**
     * Returns the distance along this geometry from its first vertex to the specified vertex.
     * @param vertex vertex index to calculate distance to
     * @returns distance to vertex (following geometry), or -1 for invalid vertex numbers
     * @note added in QGIS 2.16
     */
    double distanceToVertex( int vertex ) const;

    /**
     * Returns the bisector angle for this geometry at the specified vertex.
     * @param vertex vertex index to calculate bisector angle at
     * @returns bisector angle, in radians clockwise from north
     * @note added in QGIS 3.0
     * @see interpolateAngle()
     */
    double angleAtVertex( int vertex ) const;

    /**
     * Returns the indexes of the vertices before and after the given vertex index.
     *
     * This function takes into account the following factors:
     *
     * 1. If the given vertex index is at the end of a linestring,
     *    the adjacent index will be -1 (for "no adjacent vertex")
     * 2. If the given vertex index is at the end of a linear ring
     *    (such as in a polygon), the adjacent index will take into
     *    account the first vertex is equal to the last vertex (and will
     *    skip equal vertex positions).
     */
    void adjacentVertices( int atVertex, int& beforeVertex /Out/, int& afterVertex /Out/ ) const;

    /** Insert a new vertex before the given vertex index,
     *  ring and item (first number is index 0)
     *  If the requested vertex number (beforeVertex.back()) is greater
     *  than the last actual vertex on the requested ring and item,
     *  it is assumed that the vertex is to be appended instead of inserted.
     *  Returns false if atVertex does not correspond to a valid vertex
     *  on this geometry (including if this geometry is a Point).
     *  It is up to the caller to distinguish between
     *  these error conditions.  (Or maybe we add another method to this
     *  object to help make the distinction?)
     */
    bool insertVertex( double x, double y, int beforeVertex );

    /** Moves the vertex at the given position number
     *  and item (first number is index 0)
     *  to the given coordinates.
     *  Returns false if atVertex does not correspond to a valid vertex
     *  on this geometry
     */
    bool moveVertex( double x, double y, int atVertex );

    /** Moves the vertex at the given position number
     *  and item (first number is index 0)
     *  to the given coordinates.
    //     *  Returns false if atVertex does not correspond to a valid vertex
     *  on this geometry
     */
    bool moveVertex( const QgsPointV2& p, int atVertex );

    /** Deletes the vertex at the given position number and item
     *  (first number is index 0)
     *  Returns false if atVertex does not correspond to a valid vertex
     *  on this geometry (including if this geometry is a Point),
     *  or if the number of remaining verticies in the linestring
     *  would be less than two.
     *  It is up to the caller to distinguish between
     *  these error conditions.  (Or maybe we add another method to this
     *  object to help make the distinction?)
     */
    bool deleteVertex( int atVertex );

    /**
     *  Returns coordinates of a vertex.
     *  @param atVertex index of the vertex
     *  @return Coordinates of the vertex or QgsPoint(0,0) on error
     */
    QgsPoint vertexAt( int atVertex ) const;

    /**
     *  Returns the squared cartesian distance between the given point
     *  to the given vertex index (vertex at the given position number,
     *  ring and item (first number is index 0))
     */
    double sqrDistToVertexAt( QgsPoint& point /In/, int atVertex ) const;

    /** Returns the nearest point on this geometry to another geometry.
     * @note added in QGIS 2.14
     * @see shortestLine()
     */
    QgsGeometry nearestPoint( const QgsGeometry& other ) const;

    /** Returns the shortest line joining this geometry to another geometry.
     * @note added in QGIS 2.14
     * @see nearestPoint()
     */
    QgsGeometry shortestLine( const QgsGeometry& other ) const;

    /**
     * Searches for the closest vertex in this geometry to the given point.
     * @param point Specifiest the point for search
     * @param atVertex Receives index of the closest vertex
     * @return The squared cartesian distance is also returned in sqrDist, negative number on error
     */
    double closestVertexWithContext( const QgsPoint& point, int& atVertex /Out/ ) const;

    /**
     * Searches for the closest segment of geometry to the given point
     * @param point Specifies the point for search
     * @param minDistPoint Receives the nearest point on the segment
     * @param afterVertex Receives index of the vertex after the closest segment. The vertex
     * before the closest segment is always afterVertex - 1
     * @param leftOf Out: Returns if the point lies on the left of right side of the segment ( < 0 means left, > 0 means right )
     * @param epsilon epsilon for segment snapping (added in 1.8)
     * @return The squared cartesian distance is also returned in sqrDist, negative number on error
     */
    double closestSegmentWithContext( const QgsPoint& point, QgsPoint& minDistPoint /Out/, int& afterVertex /Out/ ) const;

    /** Adds a new ring to this geometry. This makes only sense for polygon and multipolygons.
     @return 0 in case of success (ring added), 1 problem with geometry type, 2 ring not closed,
     3 ring is not valid geometry, 4 ring not disjoint with existing rings, 5 no polygon found which contained the ring*/
    // TODO QGIS 3.0 returns an enum instead of a magic constant
    int addRing( const QList<QgsPoint>& ring );

    /** Adds a new ring to this geometry. This makes only sense for polygon and multipolygons.
     @return 0 in case of success (ring added), 1 problem with geometry type, 2 ring not closed,
     3 ring is not valid geometry, 4 ring not disjoint with existing rings, 5 no polygon found which contained the ring*/
    // TODO QGIS 3.0 returns an enum instead of a magic constant
    int addRing( QgsCurve* ring );

    /** Adds a new part to a the geometry.
     * @param points points describing part to add
     * @param geomType default geometry type to create if no existing geometry
     * @returns 0 in case of success, 1 if not a multipolygon, 2 if ring is not a valid geometry, 3 if new polygon ring
     * not disjoint with existing polygons of the feature
     */
    // TODO QGIS 3.0 returns an enum instead of a magic constant
    int addPart( const QList<QgsPoint> &points, QgsWkbTypes::GeometryType geomType = QgsWkbTypes::UnknownGeometry )/PyName=addPoints/;

    /** Adds a new part to a the geometry.
     * @param points points describing part to add
     * @param geomType default geometry type to create if no existing geometry
     * @returns 0 in case of success, 1 if not a multipolygon, 2 if ring is not a valid geometry, 3 if new polygon ring
     * not disjoint with existing polygons of the feature
     */
    // TODO QGIS 3.0 returns an enum instead of a magic constant
    int addPart( const QList<QgsPointV2> &points, QgsWkbTypes::GeometryType geomType = QgsWkbTypes::UnknownGeometry )/PyName=addPointsV2/;

    /** Adds a new part to this geometry.
     * @param part part to add (ownership is transferred)
     * @param geomType default geometry type to create if no existing geometry
     * @returns 0 in case of success, 1 if not a multipolygon, 2 if ring is not a valid geometry, 3 if new polygon ring
     * not disjoint with existing polygons of the feature
     */
    // TODO QGIS 3.0 returns an enum instead of a magic constant
    int addPart( QgsAbstractGeometry* part /Transfer/, QgsWkbTypes::GeometryType geomType = QgsWkbTypes::UnknownGeometry );

    /** Adds a new island polygon to a multipolygon feature
     * @param newPart part to add. Ownership is NOT transferred.
     * @return 0 in case of success, 1 if not a multipolygon, 2 if ring is not a valid geometry, 3 if new polygon ring
     * not disjoint with existing polygons of the feature
     * @note not available in python bindings
     */
    // TODO QGIS 3.0 returns an enum instead of a magic constant
    // int addPart( GEOSGeometry *newPart );

    /** Adds a new island polygon to a multipolygon feature
     @return 0 in case of success, 1 if not a multipolygon, 2 if ring is not a valid geometry, 3 if new polygon ring
     not disjoint with existing polygons of the feature
     @note available in python bindings as addPartGeometry (added in 2.2)
     */
    // TODO QGIS 3.0 returns an enum instead of a magic constant
    int addPart( const QgsGeometry *newPart /Transfer/ ) /PyName=addPartGeometry/;

    /** Translate this geometry by dx, dy
     @return 0 in case of success*/
    int translate( double dx, double dy );

    /** Transform this geometry as described by CoordinateTransform ct
     @return 0 in case of success*/
    int transform( const QgsCoordinateTransform& ct );

    /** Transform this geometry as described by QTransform ct
     @note added in 2.8
     @return 0 in case of success*/
    int transform( const QTransform& ct );

    /** Rotate this geometry around the Z axis
         @note added in 2.8
         @param rotation clockwise rotation in degrees
         @param center rotation center
         @return 0 in case of success*/
    int rotate( double rotation, const QgsPoint& center );

    /** Splits this geometry according to a given line.
    @param splitLine the line that splits the geometry
    @param[out] newGeometries list of new geometries that have been created with the split
    @param topological true if topological editing is enabled
    @param[out] topologyTestPoints points that need to be tested for topological completeness in the dataset
    @return 0 in case of success, 1 if geometry has not been split, error else*/
    // TODO QGIS 3.0 returns an enum instead of a magic constant
    int splitGeometry( const QList<QgsPoint>& splitLine,
                       QList<QgsGeometry*>&newGeometries /Out/,
                       bool topological,
                       QList<QgsPoint> &topologyTestPoints /Out/);

    /** Replaces a part of this geometry with another line
     * @return 0 in case of success
     * @note: this function was added in version 1.3
     */
    int reshapeGeometry( const QList<QgsPoint>& reshapeWithLine );

    /** Changes this geometry such that it does not intersect the other geometry
     * @param other geometry that should not be intersect
     * @return 0 in case of success
     */
    int makeDifference( const QgsGeometry* other );

    /** Returns the geometry formed by modifying this geometry such that it does not
     * intersect the other geometry.
     * @param other geometry that should not be intersect
     * @return difference geometry, or empty geometry if difference could not be calculated
     * @note added in QGIS 3.0
     */
    QgsGeometry makeDifference( const QgsGeometry& other ) const;

    /** Returns the bounding box of this feature*/
    QgsRectangle boundingBox() const;

    /** Test for intersection with a rectangle (uses GEOS) */
    bool intersects( const QgsRectangle& r ) const;

    /** Test for intersection with a geometry (uses GEOS) */
    bool intersects( const QgsGeometry& geometry ) const;

    /** Test for containment of a point (uses GEOS) */
    bool contains( const QgsPoint* p ) const;

    /** Test for if geometry is contained in another (uses GEOS)
     *  @note added in 1.5 */
    bool contains( const QgsGeometry& geometry ) const;

    /** Test for if geometry is disjoint of another (uses GEOS)
     *  @note added in 1.5 */
    bool disjoint( const QgsGeometry& geometry ) const;

    /** Test for if geometry equals another (uses GEOS)
     *  @note added in 1.5 */
    bool equals( const QgsGeometry& geometry ) const;

    /** Test for if geometry touch another (uses GEOS)
     *  @note added in 1.5 */
    bool touches( const QgsGeometry& geometry ) const;

    /** Test for if geometry overlaps another (uses GEOS)
     *  @note added in 1.5 */
    bool overlaps( const QgsGeometry& geometry ) const;

    /** Test for if geometry is within another (uses GEOS)
     *  @note added in 1.5 */
    bool within( const QgsGeometry& geometry ) const;

    /** Test for if geometry crosses another (uses GEOS)
     *  @note added in 1.5 */
    bool crosses( const QgsGeometry& geometry ) const;

    //! Side of line to buffer
    enum BufferSide
    {
      SideLeft, //!< Buffer to left of line
      SideRight, //!< Buffer to right of line
    };

    //! End cap styles for buffers
    enum EndCapStyle
    {
      CapRound, //!< Round cap
      CapFlat, //!< Flat cap (in line with start/end of line)
      CapSquare, //!< Square cap (extends past start/end of line by buffer distance)
    };

    //! Join styles for buffers
    enum JoinStyle
    {
      JoinStyleRound, //!< Use rounded joins
      JoinStyleMitre, //!< Use mitred joins
      JoinStyleBevel, //!< Use beveled joins
    };

    /** Returns a buffer region around this geometry having the given width and with a specified number
        of segments used to approximate curves */
    QgsGeometry buffer( double distance, int segments ) const;

    /** Returns a buffer region around the geometry, with additional style options.
     * @param distance    buffer distance
     * @param segments    for round joins, number of segments to approximate quarter-circle
     * @param endCapStyle end cap style
     * @param joinStyle   join style for corners in geometry
     * @param mitreLimit  limit on the mitre ratio used for very sharp corners (JoinStyleMitre only)
     * @note added in 2.4
     */
    QgsGeometry buffer( double distance, int segments, EndCapStyle endCapStyle, JoinStyle joinStyle, double mitreLimit ) const;

    /** Returns an offset line at a given distance and side from an input line.
     * @param distance    buffer distance
     * @param segments    for round joins, number of segments to approximate quarter-circle
     * @param joinStyle   join style for corners in geometry
     * @param mitreLimit  limit on the mitre ratio used for very sharp corners (JoinStyleMitre only)
     * @note added in 2.4
     */
    QgsGeometry offsetCurve( double distance, int segments, JoinStyle joinStyle, double mitreLimit ) const;

    /**
     * Returns a single sided buffer for a (multi)line geometry. The buffer is only
     * applied to one side of the line.
     * @param distance buffer distance
     * @param segments for round joins, number of segments to approximate quarter-circle
     * @param side side of geometry to buffer
     * @param joinStyle join style for corners
     * @param mitreLimit limit on the mitre ratio used for very sharp corners
     * @return buffered geometry, or an empty geometry if buffer could not be
     * calculated
     * @note added in QGIS 3.0
     */
    QgsGeometry singleSidedBuffer( double distance, int segments, BufferSide side,
                                   JoinStyle joinStyle = JoinStyleRound,
                                   double mitreLimit = 2.0 ) const;

    /** Returns a simplified version of this geometry using a specified tolerance value */
    QgsGeometry simplify( double tolerance )  const;

    /** Returns the center of mass of a geometry
     * @note for line based geometries, the center point of the line is returned,
     * and for point based geometries, the point itself is returned
     */
    QgsGeometry centroid() const;

    /** Returns a point within a geometry */
    QgsGeometry pointOnSurface() const;

    /** Returns the smallest convex polygon that contains all the points in the geometry. */
    QgsGeometry convexHull() const;

    /**
     * Return interpolated point on line at distance
     * @note added in 1.9
     * @see lineLocatePoint()
     */
    QgsGeometry interpolate( double distance ) const;

    /** Returns a distance representing the location along this linestring of the closest point
     * on this linestring geometry to the specified point. Ie, the returned value indicates
     * how far along this linestring you need to traverse to get to the closest location
     * where this linestring comes to the specified point.
     * @param point point to seek proximity to
     * @return distance along line, or -1 on error
     * @note only valid for linestring geometries
     * @see interpolate()
     * @note added in QGIS 3.0
     */
    double lineLocatePoint( const QgsGeometry& point ) const;

    /** Returns the angle parallel to the linestring or polygon boundary at the specified distance
     * along the geometry. Angles are in radians, clockwise from north.
     * If the distance coincides precisely at a node then the average angle from the segment either side
     * of the node is returned.
     * @param distance distance along geometry
     * @note added in QGIS 3.0
     * @see angleAtVertex()
     */
    double interpolateAngle( double distance ) const;

    /** Returns a geometry representing the points shared by this geometry and other. */
    QgsGeometry intersection( const QgsGeometry& geometry ) const;

    /** Returns a geometry representing all the points in this geometry and other (a
     * union geometry operation).
     * @note this operation is not called union since its a reserved word in C++.
     */
    QgsGeometry combine( const QgsGeometry& geometry ) const;

    /** Merges any connected lines in a LineString/MultiLineString geometry and
     * converts them to single line strings.
     * @returns a LineString or MultiLineString geometry, with any connected lines
     * joined. An empty geometry will be returned if the input geometry was not a
     * MultiLineString geometry.
     * @note added in QGIS 3.0
     */
    QgsGeometry mergeLines() const;

    /** Returns a geometry representing the points making up this geometry that do not make up other. */
    QgsGeometry difference( const QgsGeometry& geometry ) const;

    /** Returns a geometry representing the points making up this geometry that do not make up other. */
    QgsGeometry symDifference( const QgsGeometry& geometry ) const;

    /** Returns an extruded version of this geometry. */
    QgsGeometry extrude( double x, double y );

    /** Exports the geometry to WKT
     *  @note precision parameter added in 2.4
     *  @return true in case of success and false else
     */
    QString exportToWkt( int precision = 17 ) const;

    /** Exports the geometry to GeoJSON
     *  @return a QString representing the geometry as GeoJSON
     *  @note added in 1.8
     *  @note python binding added in 1.9
     *  @note precision parameter added in 2.4
     */
    QString exportToGeoJSON( int precision = 17 ) const;

    /** Try to convert the geometry to the requested type
     * @param destType the geometry type to be converted to
     * @param destMultipart determines if the output geometry will be multipart or not
     * @return the converted geometry or nullptr if the conversion fails.
     * @note added in 2.2
     */
    QgsGeometry convertToType( QgsWkbTypes::GeometryType destType, bool destMultipart = false ) const /Factory/;

    /* Accessor functions for getting geometry data */

    /** Return contents of the geometry as a point
     * if wkbType is WKBPoint, otherwise returns [0,0]
     */
    QgsPoint asPoint() const;

    /** Return contents of the geometry as a polyline
     * if wkbType is WKBLineString, otherwise an empty list
     */
    QgsPolyline asPolyline() const;

    /** Return contents of the geometry as a polygon
     * if wkbType is WKBPolygon, otherwise an empty list
     */
    QgsPolygon asPolygon() const;

    /** Return contents of the geometry as a multi point
        if wkbType is WKBMultiPoint, otherwise an empty list */
    QgsMultiPoint asMultiPoint() const;

    /** Return contents of the geometry as a multi linestring
        if wkbType is WKBMultiLineString, otherwise an empty list */
    QgsMultiPolyline asMultiPolyline() const;

    /** Return contents of the geometry as a multi polygon
        if wkbType is WKBMultiPolygon, otherwise an empty list */
    QgsMultiPolygon asMultiPolygon() const;

    /** Return contents of the geometry as a list of geometries
     @note added in version 1.1 */
    QList<QgsGeometry> asGeometryCollection() const;

    /** Return contents of the geometry as a QPointF if wkbType is WKBPoint,
     * otherwise returns a null QPointF.
     * @note added in QGIS 2.7
     */
    QPointF asQPointF() const;

    /** Return contents of the geometry as a QPolygonF. If geometry is a linestring,
     * then the result will be an open QPolygonF. If the geometry is a polygon,
     * then the result will be a closed QPolygonF of the geometry's exterior ring.
     * @note added in QGIS 2.7
     */
    QPolygonF asQPolygonF() const;

    /** Delete a ring in polygon or multipolygon.
      Ring 0 is outer ring and can't be deleted.
      @return true on success
      @note added in version 1.2 */
    bool deleteRing( int ringNum, int partNum = 0 );

    /** Delete part identified by the part number
      @return true on success
      @note added in version 1.2 */
    bool deletePart( int partNum );

    /**
     * Converts single type geometry into multitype geometry
     * e.g. a polygon into a multipolygon geometry with one polygon
     * If it is already a multipart geometry, it will return true and
     * not change the geometry.
     *
     * @return true in case of success and false else
     */
    bool convertToMultiType();

    /**
     * Converts multi type geometry into single type geometry
     * e.g. a multipolygon into a polygon geometry. Only the first part of the
     * multi geometry will be retained.
     * If it is already a single part geometry, it will return true and
     * not change the geometry.
     *
     * @return true in case of success and false else
     */
    bool convertToSingleType();

    /** Modifies geometry to avoid intersections with the layers specified in project properties
     *  @return 0 in case of success,
     *          1 if geometry is not of polygon type,
     *          2 if avoid intersection would change the geometry type,
     *          3 other error during intersection removal
     *  @param ignoreFeatures possibility to give a list of features where intersections should be ignored (not available in python bindings)
     *  @note added in 1.5
     */
    int avoidIntersections();

    class Error
    {
      public:
        Error();
        Error( const QString& m );
        Error( const QString& m, const QgsPoint& p );

        QString what();
        QgsPoint where();
        bool hasWhere();
    };

    /** Validate geometry and produce a list of geometry errors
     * @note added in 1.5
     * @note python binding added in 1.6
     **/
    void validateGeometry( QList<QgsGeometry::Error> &errors /Out/ );

    /** Compute the unary union on a list of geometries. May be faster than an iterative union on a set of geometries.
     * @param geometryList a list of QgsGeometry* as input
     * @returns the new computed QgsGeometry, or null
     */
    static QgsGeometry unaryUnion( const QList<QgsGeometry>& geometryList );

    /** Converts the geometry to straight line segments, if it is a curved geometry type.
     * @note added in QGIS 2.10
     * @see requiresConversionToStraightSegments
     */
    void convertToStraightSegment();

    /** Returns true if the geometry is a curved geometry type which requires conversion to
     * display as straight line segments.
     * @note added in QGIS 2.10
     * @see convertToStraightSegment
     */
    bool requiresConversionToStraightSegments() const;

    /** Transforms the geometry from map units to pixels in place.
     * @param mtp map to pixel transform
     * @note added in QGIS 2.10
     */
    void mapToPixel( const QgsMapToPixel& mtp );

    // not implemented for 2.10
    /* Clips the geometry using the specified rectangle
     * @param rect clip rectangle
     * @note added in QGIS 2.10
     */
    // void clip( const QgsRectangle& rect );

    /** Draws the geometry onto a QPainter
     * @param p destination QPainter
     * @note added in QGIS 2.10
     */
    void draw( QPainter& p ) const;

    /** Calculates the vertex ID from a vertex number
     * @param nr vertex number
     * @param id reference to QgsVertexId for storing result
     * @returns true if vertex was found
     * @note added in QGIS 2.10
     * @see vertexNrFromVertexId
     */
    bool vertexIdFromVertexNr( int nr, QgsVertexId& id ) const;

    /** Returns the vertex number corresponding to a vertex idd
     * @param i vertex id
     * @returns vertex number
     * @note added in QGIS 2.10
     * @see vertexIdFromVertexNr
     */
    int vertexNrFromVertexId( QgsVertexId i ) const;

    /** Return GEOS context handle
     * @note added in 2.6
     * @note not available in Python
     */
    // static GEOSContextHandle_t getGEOSHandler();

    /** Construct geometry from a QPointF
     * @param point source QPointF
     * @note added in QGIS 2.7
     */
    static QgsGeometry fromQPointF( QPointF point );

    /** Construct geometry from a QPolygonF. If the polygon is closed than
     * the resultant geometry will be a polygon, if it is open than the
     * geometry will be a polyline.
     * @param polygon source QPolygonF
     * @note added in QGIS 2.7
     */
    static QgsGeometry fromQPolygonF( const QPolygonF& polygon );

    /** Creates a QgsPolyline from a QPolygonF.
     * @param polygon source polygon
     * @returns QgsPolyline
     * @see createPolygonFromQPolygonF
     */
    static QgsPolyline createPolylineFromQPolygonF( const QPolygonF &polygon ) /Factory/;

    /** Creates a QgsPolygon from a QPolygonF.
     * @param polygon source polygon
     * @returns QgsPolygon
     * @see createPolylineFromQPolygonF
     */
    static QgsPolygon createPolygonFromQPolygonF( const QPolygonF &polygon ) /Factory/;

    /** Compares two polylines for equality within a specified tolerance.
     * @param p1 first polyline
     * @param p2 second polyline
     * @param epsilon maximum difference for coordinates between the polylines
     * @returns true if polylines have the same number of points and all
     * points are equal within the specified tolerance
     * @note added in QGIS 2.9
     */
    static bool compare( const QgsPolyline& p1, const QgsPolyline& p2, double epsilon = 4 * DBL_EPSILON );
    static bool compare( const QgsPolyline& p1, const QgsPolyline& p2, double epsilon = 4 * DBL_EPSILON )/PyName=comparePolylines/;

    /** Compares two polygons for equality within a specified tolerance.
     * @param p1 first polygon
     * @param p2 second polygon
     * @param epsilon maximum difference for coordinates between the polygons
     * @returns true if polygons have the same number of rings, and each ring has the same
     * number of points and all points are equal within the specified tolerance
     * @note added in QGIS 2.9
     */
    static bool compare( const QgsPolygon& p1, const QgsPolygon& p2, double epsilon = 4 * DBL_EPSILON );
    static bool compare( const QgsPolygon& p1, const QgsPolygon& p2, double epsilon = 4 * DBL_EPSILON )/PyName=comparePolygons/;

    /** Compares two multipolygons for equality within a specified tolerance.
     * @param p1 first multipolygon
     * @param p2 second multipolygon
     * @param epsilon maximum difference for coordinates between the multipolygons
     * @returns true if multipolygons have the same number of polygons, the polygons have the same number
     * of rings, and each ring has the same number of points and all points are equal within the specified
     * tolerance
     * @note added in QGIS 2.9
     */
    static bool compare( const QgsMultiPolygon& p1, const QgsMultiPolygon& p2, double epsilon = 4 * DBL_EPSILON );
    static bool compare( const QgsMultiPolygon& p1, const QgsMultiPolygon& p2, double epsilon = 4 * DBL_EPSILON )/PyName=compareMultiPolygons/;

    /** Smooths a geometry by rounding off corners using the Chaikin algorithm. This operation
     * roughly doubles the number of vertices in a geometry.
     * @param iterations number of smoothing iterations to run. More iterations results
     * in a smoother geometry
     * @param offset fraction of line to create new vertices along, between 0 and 1.0
     * eg the default value of 0.25 will create new vertices 25% and 75% along each line segment
     * of the geometry for each iteration. Smaller values result in "tighter" smoothing.
     * @param minimumDistance minimum segment length to apply smoothing to
     * @param maxAngle maximum angle at node (0-180) at which smoothing will be applied
     * @note added in 2.9
     */
    QgsGeometry smooth( const unsigned int iterations = 1, const double offset = 0.25,
                        double minimumDistance = -1.0, double maxAngle = 180.0 ) const;

    /** Creates and returns a new geometry engine
     */
    static QgsGeometryEngine* createGeometryEngine( const QgsAbstractGeometry* geometry ) /Factory/;

    /** Upgrades a point list from QgsPoint to QgsPointV2
     * @param input list of QgsPoint objects to be upgraded
     * @param output destination for list of points converted to QgsPointV2
     */
    static void convertPointList( const QList<QgsPoint>& input, QList<QgsPointV2>& output );

    /** Downgrades a point list from QgsPointV2 to QgsPoint
     * @param input list of QgsPointV2 objects to be downgraded
     * @param output destination for list of points converted to QgsPoint
     */
    static void convertPointList( const QList<QgsPointV2>& input, QList<QgsPoint>& output );

    //! Allows direct construction of QVariants from geometry.
    operator QVariant() const;

    /** Returns true if the geometry is non empty (ie, isEmpty() returns false),
     * or false if it is an empty, uninitialised geometry (ie, ieEmpty() returns true).
     * @note added in QGIS 3.0
     */
    operator bool() const;

}; // class QgsGeometry

