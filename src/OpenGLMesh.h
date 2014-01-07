/*!
 * \file OpenGLMesh.h
 * \brief OpenGL Mesh
 *
 * \author Mongoose
 *
 * \todo Unify the parallel systems here, arrays and the allocate/set
 */

#ifndef GUARD__OPENRAIDER_MONGOOSE_OPENGLMESH_H_
#define GUARD__OPENRAIDER_MONGOOSE_OPENGLMESH_H_

#include "hel/math.h"

class OpenGLMesh {
public:

    typedef enum {
        OpenGLMeshModeSolid          = 0,
        OpenGLMeshModeWireframe      = 1,
        OpenGLMeshModeTexture        = 2,
        OpenGLMeshModeMultiTexture   = 3
    } OpenGLMeshMode;

    typedef enum {
        fOpenGLMesh_Transparent      = 1,
        fOpenGLMesh_BumpMap          = 2,
        fOpenGLMesh_UseVertexArray   = 4
    } OpenGLMeshFlags;

    typedef struct tris_s {
        int texture;
#ifdef MULTITEXTURE
        int bumpmap;
#endif

        unsigned int cnum_triangles;
        unsigned int cnum_alpha_triangles;

        unsigned int num_texcoors;
        vec2_t *texcoors;

        unsigned int num_texcoors2;
        vec2_t *texcoors2;

        //! Arrays of triangle indices sorted by texture
        unsigned int num_triangles;
        unsigned int *triangles; //!< ABCABCABC...

        //! Arrays of alpha triangle indices sorted by texture
        unsigned int num_alpha_triangles;
        unsigned int *alpha_triangles; //!< ABCABCABC...
    } tris_t;

    typedef struct rect_s {

        int texture;
#ifdef MULTITEXTURE
        int bumpmap;
#endif

        unsigned int cnum_quads;
        unsigned int cnum_alpha_quads;

        unsigned int num_texcoors;
        vec2_t *texcoors;

        unsigned int num_texcoors2;
        vec2_t *texcoors2;

        //! Arrays of rectangle indices sorted by texture
        unsigned int num_quads;
        unsigned int *quads; //!< ABCDABCDABCD...

        //! Arrays of alpha rectangle indices sorted by texture
        unsigned int num_alpha_quads;
        unsigned int *alpha_quads; //!< ABCDABCDABCD...

    } rect_t;

    ////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////

    /*!
     * \brief Constructs an object of OpenGLMesh
     */
    OpenGLMesh();

    /*!
     * \brief Deconstructs an object of OpenGLMesh
     */
    ~OpenGLMesh();


    ////////////////////////////////////////////////////////////
    // Public Accessors
    ////////////////////////////////////////////////////////////


    void drawAlpha();


    void drawSolid();


    ////////////////////////////////////////////////////////////
    // Public Mutators
    ////////////////////////////////////////////////////////////


    void allocateColors(unsigned int n);


    void allocateNormals(unsigned int n);


    void allocateRectangles(unsigned int n);


    void allocateTriangles(unsigned int n);


    void allocateVertices(unsigned int n);


    void bufferColorArray(unsigned int colorCount, vec_t *colors,
                                 unsigned int colorWidth);


    void bufferNormalArray(unsigned int normalCount, vec_t *normals);


    void bufferTriangles(unsigned int count,
                                unsigned int *indices, vec_t *texCoords,
                                int *textures, unsigned int *flags);

    void bufferVertexArray(unsigned int vertexCount, vec_t *vertices);


    void setColor(unsigned int index, float r, float g, float b, float a);


    void setColor(unsigned int index, float rgba[4]);


    void setNormal(unsigned int index, float i, float j, float k);


    void setVertex(unsigned int index, float x, float y, float z);

#ifdef NOT_IMPLEMENTED


    void sortFacesByTexture();


    void addFace(int textureIndex, int textureIndexB, unsigned int flags,
                     unsigned int vertexIndexCount, vec_t *vertexIndices);


    void addTexTiledFace(int textureIndex, int textureIndexB,
                                unsigned int flags, unsigned int indexCount,
                                vec_t *vertexIndices, vec_t *texcoords);


    void bufferTexcoords(unsigned int texcoordCount, vec_t *texcoords);


    void duplicateArraysForTexTiledTexcoords();

#endif

    unsigned int mFlags;

    OpenGLMeshMode mMode;

    unsigned int mNumVertices;
    vec3_t *mVertices; //!< XYZ

    unsigned int mNumNormals;
    vec3_t *mNormals; //!< IJK

    unsigned int mNumColors;
    vec4_t *mColors; //!< RGBA

    unsigned int mNumTris;
    tris_t *mTris;

    unsigned int mNumQuads;
    rect_t *mQuads;

    unsigned int mTriangleCount;
    int *mTriangleTextures;
    unsigned int *mTriangleIndices;
    unsigned int *mTriangleFlags;
    vec_t *mTriangleTexCoordArray;

    vec_t *mVertexArray;
    vec_t *mNormalArray;
    vec_t *mColorArray;

private:

    ////////////////////////////////////////////////////////////
    // Private Accessors
    ////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////
    // Private Mutators
    ////////////////////////////////////////////////////////////

};

#endif
