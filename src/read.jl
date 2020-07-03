
function read_xml(io::Union{IO, AbstractString})
	xml = EzXML.readxml(io)
	return _parse_document(xml)
end

function parse_xml(xmlstring::AbstractString)
	xml = EzXML.parsexml(xmlstring)
	return _parse_document(xml)
end

function _parse_document(xml::EzXML.Document)

    data, cnpj, tipo = _parse_documento_ddr(xml)
    nome, telefone, email = _parse_parametros(xml)

    responsavel = Responsavel(nome, telefone, email)

    contas = _parse_contas(xml)

	doc = Doc2011(data, cnpj, tipo, responsavel, contas)
	return doc

end

function _parse_documento_ddr(xml::EzXML.Document)

	node = findfirst("/documentoDDR", xml)

	@assert node != nothing "nao encontrou node documentoDDR"

	str_data = node["dataBase"]
	data = Dates.Date(str_data, Dates.DateFormat("yyyy-mm-dd"))

	cnpj = node["cnpj"]

	str_tipo_envio = node["tipoEnvio"]
	tipo = decode_tipo_envio(str_tipo_envio)

	return data, cnpj, tipo

end

function _parse_parametros(xml::EzXML.Document)

	node_nome = findfirst("/documentoDDR/parametros/parametro[@codigoParametro='31']", xml)
	@assert node_nome != nothing "nao encontrou parametro nome (codigo 31)"
	nome = node_nome["valorParametro"]

	node_telefone = findfirst("/documentoDDR/parametros/parametro[@codigoParametro='32']", xml)
	@assert node_telefone != nothing "nao encontrou parametro telefone (codigo 32)"
	telefone = node_telefone["valorParametro"]

	node_email = findfirst("/documentoDDR/parametros/parametro[@codigoParametro='33']", xml)
	@assert node_email != nothing "nao encontrou parametro email (codigo 33)"
	email = node_email["valorParametro"]

	return nome, telefone, email

end

function _parse_contas(xml::EzXML.Document)::Vector{Conta}

	out = Vector{Conta}()

	nodes = findall("/documentoDDR/contas/conta", xml)

	for node in nodes
		codigo = node["codigoConta"]
		try
			valor = parse(Float64, node["valorConta"])
			detalhes = _parse_detalhes(node)
			conta = Conta(codigo, valor, detalhes)
			push!(out, conta)
		catch e
			error("erro ao ler conta $codigo: $e")
		end

	end

	return out

end

function _parse_detalhes(node_conta::EzXML.Node)::Vector{DetalheConta}

	out = Vector{DetalheConta}()
	nodes = findall("detalhamentosDDR/detalhamentoDDR", node_conta)

	for node in nodes
		valor_detalhe = parse(Float64, node["valorDetalhe"])
		elementos = Vector{ElementoDetalhe}()
		detalhes = findall("detalhe", node)
		for detalhe in detalhes
			codigo = detalhe["codigoElemento"]
			valor = detalhe["valorElemento"]
			elemento_detalhe = _parse_elemento_detalhe(codigo, valor)
			push!(elementos, elemento_detalhe)
		end
		detalhe_conta = DetalheConta(elementos, valor_detalhe)
		push!(out, detalhe_conta)
	end

	return out
end

function _parse_elemento_detalhe(codigo::String, valor::String)::ElementoDetalhe

	T = _decode_tipo_elemento_detalhe(codigo)
	return T(valor) # usando construtor com string

end

function _decode_tipo_elemento_detalhe(codigo::String)::DataType

	if codigo == "81"
		return Pais
	elseif codigo == "83"
		return Moeda
	elseif codigo == "84"
		return Posicao
	else
		error("codigoElemento invalido: $codigo")
	end

end
