function typeStr=mapId2TypeString2EN(classId)
classTable={
    'notSign','20','25','30','45','60','80','crossroad','crossroad','crossroad','crossroad','bridge','Two Way','Joint way','Traffic Lights','U-Turn','Left','Across the street'...,
    'Across the street','Keep Left','Circus','Do not park','slope','plane','Do Not Overtake','Do not turn left','Do not stop','Pathway','No Motorcycle','No passing','Stop','Direct','Turn right'...,
    'bike','Do not U-turn','Keep Left or Right','Do not park','Direct or Right','IN','OUT','Parking','Turn Right','Right','zigzag','ขับตรงไป','Joint way'...,
    'Turn Left','4 separate split','Give way','Do not Turn Left','Do not keep Left'
};
typeStr=classTable(classId);
end


