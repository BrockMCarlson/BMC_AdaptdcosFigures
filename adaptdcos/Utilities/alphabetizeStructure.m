[~, neworder] = sort(lower(fieldnames(rez.ops)));
newstructure = orderfields(rez.ops, neworder);
