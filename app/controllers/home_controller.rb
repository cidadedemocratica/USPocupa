class HomeController < ApplicationController

  caches_action :index, :expires_in => 1.minute, :layout => false

  # Ante sala do site
  def index
    @cidades = Cidade.mais_ativas(:order => "cidades.relevancia DESC",
                                  :limit => @settings["home_cloud_items"].to_i).sort_by { |c| c.nome }
    @tags = Tag.do_contexto(:pais => nil,
                            :estado => nil,
                            :cidade => nil,
                            :bairro => nil,
                            :topico_type => nil,
                            :ultimos_dias => nil,
                            :order => "tags.relevancia DESC",
                            :limit => @settings["home_cloud_items"].to_i)
    @usuarios = User.nao_admin.ativos.com_avatar.aleatorios.find(:all, :limit => 8)
  
    @topicos = Topico.de_user_ativo.find(:all, :include => [:locais], :order => "topicos.id DESC", :limit => @settings["home_numero_topicos"].to_i)
    @topicos_mais_comentados = Topico.de_user_ativo.find(:all, :include => [:locais], :order => "topicos.comments_count DESC", :limit => @settings["home_numero_topicos"].to_i)
    @topicos_mais_apoiados   = Topico.de_user_ativo.find(:all, :include => [:locais], :order => "topicos.adesoes_count DESC", :limit => @settings["home_numero_topicos"].to_i)
  
    @apoios = Adesao.por_user_ativo.find(:all, :include => [:user, :topico], :order => "adesoes.created_at DESC", :limit => @settings["home_numero_apoios"].to_i)
    @seguidores = Seguido.por_user_ativo.find(:all, :include => [:topico], :order => "seguidos.created_at DESC", :limit => @settings["home_numero_seguidores"].to_i)
    @comentarios = Comentario.de_user_ativo.find(:all, :order => "comments.id DESC", :limit => @settings["home_numero_comentarios"].to_i)
  end
  
  # Home da cidade
  def cidade
    case params[:order]
      when "relevancia"
        order = "topicos.relevancia DESC"
      when "recentes"
        order = "topicos.created_at DESC"
      when "antigos"
        order = "topicos.created_at ASC"
      when "mais_comentarios"
        order = "topicos.comments_count DESC"
      when "mais_apoios"
        order = "topicos.adesoes_count DESC"
      when "a-z"
        order = "topicos.titulo ASC"
      when "z-a"
        order = "topicos.titulo DESC"
      else
        params[:order] = "relevancia"
        order = "topicos.relevancia DESC"
    end
    
    @tags = Topico.tags_por_cidade(@cidade_corrente.id, :limit => 60).sort{ |a,b| a.name <=> b.name }
    @topicos = Topico.da_cidade(@cidade_corrente.id).find(:all, :limit => 8, :order => order)
    @bairros = Bairro.de_topicos(@cidade_corrente.id)
    @estatisticas = {
      :pessoas => Cidadao.da_cidade(@cidade_corrente.id).count,
      :propostas => Proposta.da_cidade(@cidade_corrente.id).count,
      :problemas => Problema.da_cidade(@cidade_corrente.id).count
    }
    # @ultimos_comentarios = [] #Comment.find(Topico)
    # troquei :order => "users.relevancia DESC" por "aleatorios" para mostrar alguma aleatoriedade
    @usuarios_mais_engajados = User.ativos.nao_admin.da_cidade(@cidade_corrente.id).aleatorios.find(:all, :include => :dado, :limit => 7)

    @contadores = Hash.new
    @contadores[:users] = User.da_cidade(@cidade_corrente.id).size
    @contadores[:propostas] = Proposta.da_cidade(@cidade_corrente.id).size
    @contadores[:problemas] = Problema.da_cidade(@cidade_corrente.id).size
  end
  
  # Lista de todas as tags do site
  def temas
    @tags = Tag.find(:all, Topico.find_options_for_tag_counts(:order => "name ASC"))
  end
  
  def termos_de_uso
  end
  
  def tour
  end

  def ajuda
  end

  def boas_praticas
  end

  def quem_somos
  end

  def para_cidadaos
  end

  def para_entidades
  end

end
