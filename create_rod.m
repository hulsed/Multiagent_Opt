% Given a material, length, diameter, and thickness, creates a rod object
% with additional useful properties
function rod = create_rod(material, length, diameter, thickness)
    rod.mat = material;
    rod.Length = length;
    rod.Dia = diameter;
    rod.Thick = thickness;
    rod.Area=.5*pi*(rod.Dia^2-(rod.Dia-rod.Thick)^2);
    rod.Amoment=pi*(rod.Dia^2-(rod.Dia-rod.Thick)^2)/64; %area moment of inertia
    Rod.Stiffness=(rod.Length^3/(3*rod.Amoment*1e9*rod.mat.Ymod))^-1;
    rod.Vol=rod.Length*rod.Area;
    rod.Mass=rod.Vol*rod.mat.Dens; % in kg
    rod.Cost=rod.mat.Cost*rod.Vol;
end