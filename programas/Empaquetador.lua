--Empaquetador de archivos. Adaptado de File Packager de oeed, en ComputerCraft Forums.

sPackage = "local pkg = %@1 local function makeFile(_path, _content) local file = fs.open(_path, \"w\") _content = _content:gsub(\"\!@\"..\"#&\", \"%\\n\") _content = textutils.unserialize(_content) file.write(_content) file.close() end local function makeFolder(_path, _content) fs.makeDir(_path) for k,v in pairs(_content) do if type(v) == \"table\" then makeFolder(_path .. \"/\" .. k, v) else makeFile(_path .. \"/\" .. k, v) end end end local sDest = shell.resolve( \"%@2\" ) or \"/\" if sDest == \"root\" then sDest = \"/\" end local tPackage = pkg makeFolder(sDest, tPackage) if olive.version() then olive.throwMsg(\"Information\",\"Package Extracted to '\" .. sDest .. \"'!\") else print(\"Package Extracted to '\" .. sDest .. \"'!\") end"

function addFile(_package, _path)
        if fs.getName(_path) == ".DS_Store" then
                return _package
        end
        local file, err = fs.open(_path, "r")
        local content = file.readAll()
        content = content:gsub("%\n", "\!@".."#&")
        content = content:gsub("%%", "%%%%")
        _package[fs.getName(_path)] = content
        file.close()
	olive.throwWait("Informarcion","Adjuntado '".._path.."'")
	tamx,tamy=term.getSize()
	olive.square(1,tamy/2-1,tamx,3, colors.black)
	return _package,_path
end

function addFolder(_package, _path)
        if string.sub(_path,1,string.len("rom"))=="rom" or string.sub(_path,1,string.len("/rom"))=="/rom" then
		olive.throwWait("Carpeta ignorada",_path)
                return
        end
        _package = _package or {}
        for _,f in ipairs(fs.list(_path)) do
                local path = _path.."/"..f
                if fs.isDir(path) then
                        _package[fs.getName(f)] = addFolder(_package[fs.getName(f)], path)
                else
                        isError,_package,_ruta =  pcall(addFile, _package, path)
						if isError then olive.throwError(_ruta) end
                end
        end
        return _package,_path
end

local tArgs = { ... }
if #tArgs < 2 then
        deci1=olive.entraNombre("Carpeta de origen",48)
		deci2=olive.entraNombre("Carpeta de destino",48)
		tArgs={deci1,deci2}
end
 
local sSource = shell.resolve( tArgs[1] )
local sDest = shell.resolve( tArgs[2] )
 
if fs.isDir( sDest ) then
	error("El destino no puede ser una carpeta.")
end

if sSource == sDest then
	error("El origen no puede ser igual al destino.")
end

if fs.exists( sSource ) and fs.isDir( sSource ) then
        tPackage = {}
        isError,tPackage,path = pcall(addFolder,tPackage, sSource)
		if isError then
			if type(tPackage)==table then
				tPackage=textutils.unserialize(tPackage)
			end
			olive.throwError(path)
		end
        fPackage = fs.open(sDest,"w")
 
        sPackage = string.gsub(sPackage, "%%@2", fs.getName(sSource))
        sPackage = string.gsub(sPackage, "%%@1", textutils.serialize(tPackage))
        fPackage.write(sPackage)
        fPackage.close()
	olive.throwMsg("Informacion","Paquete listo! ('" .. sDest .. "')")
else
	error("El origen no existe o no es una carpeta")
end