# Special case of inertial [mass, x, y, z, Ixx, Iyy, Izz] buildup
struct InertialElement{TF}
    mass::TF
    xcg::TF
    ycg::TF
    zcg::TF
    Ixx::TF
    Iyy::TF
    Izz::TF
end
InertialElement(mass=0., xcg=mass*0., ycg=mass*0., zcg=mass*0., Ixx=mass*0., Iyy=mass*0., Izz=mass*0.) = InertialElement(promote(mass, xcg, ycg, zcg, Ixx, Iyy, Izz)...)

Base.copy(IE::InertialElement) = InertialElement(IE.mass, IE.xcg, IE.ycg, IE.zcg, IE.Ixx, IE.Iyy, IE.Izz,)

Base.show(io::IO, IE::InertialElement) = Base.show(io, tuple(IE.mass, IE.xcg, IE.ycg, IE.zcg, IE.Ixx, IE.Iyy, IE.Izz)) # using depth of 3

function Base.:(+)(a::InertialElement{T1} where T1, b::InertialElement{T2} where T2)
    mass = a.mass + b.mass
    
    xcg = (a.xcg*a.mass + b.xcg*b.mass)/mass
    ycg = (a.ycg*a.mass + b.ycg*b.mass)/mass
    zcg = (a.zcg*a.mass + b.zcg*b.mass)/mass

    Ixx = (a.Ixx + a.mass * ((a.ycg-ycg)^2 + (a.zcg-zcg)^2)
         + b.Ixx + b.mass * ((b.ycg-ycg)^2 + (b.zcg-zcg)^2))
        
    Iyy = (a.Iyy + a.mass * ((a.zcg-zcg)^2 + (a.xcg-xcg)^2)
         + b.Iyy + b.mass * ((b.zcg-zcg)^2 + (b.xcg-xcg)^2))

    Izz = (a.Izz + a.mass * ((a.ycg-ycg)^2 + (a.xcg-xcg)^2)
         + b.Izz + b.mass * ((b.ycg-ycg)^2 + (b.xcg-xcg)^2))

    return InertialElement(mass, xcg, ycg, zcg, Ixx, Iyy, Izz)
end
InertiaBuildUp(name::Symbol) = BuildUp(name, InertialElement())
