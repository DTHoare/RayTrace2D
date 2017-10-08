/*---------------------------------------------------------------
Surface
An extension of the Line class, has properties for surfaces
----------------------------------------------------------------*/

class Surface extends Line {
  float albedo;
  float diffusivity;
  
  Surface(PVector p1, PVector p2, float albedo_, float diffusivity_){
    super(p1, p2);
    albedo = albedo_;
    diffusivity = diffusivity_;
  }
  
}