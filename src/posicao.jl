
get_codigo_elemento(::Posicao)::String = "84"

function get_valor_elemento(p::Posicao)
    if p.codigo == :onshore
        return "1"
    elseif p.codigo == :offshore
        return "2"
    else
        error("unicorn")
    end
end

CONST_POSICOES = [:onshore, :offshore]
