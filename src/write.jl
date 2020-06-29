
function to_xml(doc::Doc2011)
    xml = XMLDocumentNode("1.0")
    ddr = addelement!(xml, "documentoDDR")
    link!(ddr, AttributeNode("cnpj", doc.cnpj))
    link!(ddr, AttributeNode("dataBase", Dates.format(doc.data, "yyyy-mm-dd")))
    link!(ddr, AttributeNode("codigoDocumento", "2011"))
    link!(ddr, AttributeNode("tipoEnvio", encode(doc.tipo)))

    parametros = addelement!(ddr, "parametros")
    add_parametro!(parametros, "31", doc.responsavel.nome)
    add_parametro!(parametros, "32", doc.responsavel.telefone)
    add_parametro!(parametros, "33", doc.responsavel.email)

    contas = addelement!(ddr, "contas")
    for conta in doc.contas
        conta.valor >= 0.01 && add_conta!(contas, conta)
    end

    return xml
end

function add_parametro!(node::EzXML.Node, codigo::String, valor::String)
    par = addelement!(node, "parametro")
    link!(par, AttributeNode("codigoParametro", codigo))
    link!(par, AttributeNode("valorParametro", valor))
    return par
end

function add_conta!(node::EzXML.Node, conta::Conta)
    elm = addelement!(node, "conta")
    link!(elm, AttributeNode("codigoConta", conta.codigo))
    str_valor = @sprintf("%.2f", round(conta.valor, digits=2))
    link!(elm, AttributeNode("valorConta", str_valor))

    if length(conta.detalhes) > 0
        detalhes = addelement!(elm, "detalhamentosDDR")
        for detalhe in conta.detalhes
            detalhe.valor >= 0.01 && add_detalhe!(detalhes, detalhe)
        end
    end

    return elm
end

function add_detalhe!(node::EzXML.Node, detalhe::DetalheConta)
    # moeda::Symbol
    # posicao::Symbol # :onshore ou :offshore
    # valor::Float64
    dd = addelement!(node, "detalhamentoDDR")
    str_valor = @sprintf("%.2f", round(detalhe.valor, digits=2))
    link!(dd, AttributeNode("valorDetalhe", str_valor))

    for el in detalhe.elementos
        node = addelement!(dd, "detalhe")
        link!(node, AttributeNode("codigoElemento", get_codigo_elemento(el)))
        link!(node, AttributeNode("valorElemento", get_valor_elemento(el)))
    end

    return dd
end

write_xml(io::IO, doc::Doc2011) = prettyprint(io, to_xml(doc))
write_xml(path::String, doc::Doc2011) = open(path, "w+") do io write_xml(io, doc) end
