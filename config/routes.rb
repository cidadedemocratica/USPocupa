ActionController::Routing::Routes.draw do |map|
  # Configurações
  tipos_de_topico = Regexp.new('(topicos|problemas|propostas)')
  ordem_de_topico = Regexp.new('(relevancia|recentes|antigos|mais_comentarios|mais_apoios|a-z|z-a)')
  tipos_de_rss    = Regexp.new('(rss)')

  tipos_de_usuario = Regexp.new('(cidadaos|gestores_publicos|empresas|ongs|poderes_publicos|parlamentares|universidades|movimentos)')
  ordem_de_usuario = Regexp.new('(relevancia|recentes|mais_topicos|mais_comentarios|mais_apoios|a-z|z-a)')

  estado = Regexp.new('[a-z]{2}')
  cidade = Regexp.new('[a-zA-Z-]+')

  apenas_letras  = Regexp.new('[a-zA-Z-]+')
  apenas_numeros = Regexp.new('[0-9]+')

  #=============================================================================================#
  #  Aplicação para o USUÁRIO: Login, logout, cadastro, confirmação, perfil, observatorio etc.
  #=============================================================================================#
  map.logout "/logout", :controller => "sessions", :action => "destroy"
  map.login "/login", :controller => "sessions", :action => "new"
  map.cadastrar "/usuario/cadastrar", :controller => "users", :action => "new"
  map.activation "/usuario/confirmar/:activation_code", :controller => "users", :action => "activate"
  map.completar_cadastro "/usuario/completar_cadastro", :controller => "users", :action => "complete"
  map.aguardando_confirmacao "/usuario/aguardando_confirmacao", :controller => "users", :action => "aguardando_confirmacao"
  map.connect "/usuario/pwdrst/:id_criptografado/:crypted_password/:salt", :controller => "users", :action => "pwdrst"
  map.reset_password "/usuario/reset_password", :controller => "users", :action => "reset_password"

  map.vincular "/vincular/:user_id_criptografado", :controller => "users", :action => "vincular"
  map.solicitar_vinculacao "/solicitar_vinculacao/:organizacao_id", :controller => "users", :action => "solicitar_vinculacao"

  # Perfil do usuário: dados pessoais, local, avatar, tópicos, comentários, funcionários, etc.
  map.perfil "/perfil/:id", :controller => "users", :action => "show", :requirements => { :id => apenas_numeros }
  map.perfil_rss "/perfil/:id.:format", :controller => "users", :action => "show", :requirements => { :id => apenas_numeros }
  map.perfil_json "/perfil/:id.:format", :controller => "users", :action => "show", :requirements => { :id => apenas_numeros }
  map.perfil_mensagem "/perfil/:id/mensagem", :controller => "users", :action => "mensagem", :requirements => { :id => apenas_numeros }
  map.connect "/perfil/dados_basicos", :controller => "users", :action => "edit"
  map.connect "/perfil/localizacao", :controller => "users", :action => "localizacao"
  map.connect "/perfil/avatar", :controller => "avatar", :action => "new"
  map.connect "/perfil/avatar/resize", :controller => "avatar", :action => "resize"
  map.connect "/perfil/avatar/salvar", :controller => "avatar", :action => "create"
  map.connect "/perfil/avatar/remover", :controller => "avatar", :action => "destroy"
  map.trocar_senha "/perfil/trocar_senha", :controller => "users", :action => "trocar_senha"
  map.descadastrar "/perfil/descadastrar", :controller => "users", :action => "descadastrar"
  map.confirma_descadastro "/perfil/confirma_descadastro", :controller => "users", :action => "confirma_descadastro"

  #=====================================================#
  #   URLS dos USUÁRIOS (atenção: N Usuários, listas...)
  #=====================================================#
  # Navegação por usuários: com todos os parametros
  map.connect "/usuarios/:user_type/estado/:estado_abrev/cidade/:cidade_slug/bairro/:bairro_id/:user_order",
               :controller => "users",
               :action => "index",
               :user_order => nil,
               :requirements => {
                 :user_type => tipos_de_usuario,
                 :estado_abrev => estado,
                 :cidade_slug => cidade,
                 :bairro_id => apenas_numeros,
                 :user_order => ordem_de_usuario
                }
  # Na cidade...
  map.connect "/usuarios/:user_type/estado/:estado_abrev/cidade/:cidade_slug/:user_order",
               :controller => "users",
               :action => "index",
               :user_order => nil,
               :requirements => {
                 :user_type => tipos_de_usuario,
                 :estado_abrev => estado,
                 :cidade_slug => cidade,
                 :user_order => ordem_de_usuario
                }
  map.connect "/usuarios/estado/:estado_abrev/cidade/:cidade_slug/:user_order",
               :controller => "users",
               :action => "index",
               :user_order => nil,
               :requirements => {
                 :estado_abrev => estado,
                 :cidade_slug => cidade,
                 :user_order => ordem_de_usuario
                }
  # No estado...
  map.connect "/usuarios/:user_type/estado/:estado_abrev/:user_order",
               :controller => "users",
               :action => "index",
               :user_order => nil,
               :requirements => {
                 :user_type => tipos_de_usuario,
                 :estado_abrev => estado,
                 :user_order => ordem_de_usuario
                }
  map.connect "/usuarios/estado/:estado_abrev/:user_order",
               :controller => "users",
               :action => "index",
               :user_order => nil,
               :requirements => {
                 :estado_abrev => estado,
                 :user_order => ordem_de_usuario
                }
  # Apenas separando os tipos...
  map.connect "/usuarios/:user_type/:user_order",
               :controller => "users",
               :action => "index",
               :user_order => nil,
               :requirements => {
                 :user_type => tipos_de_usuario,
                 :user_order => ordem_de_usuario
                }
  # Em todo o site...
  map.usuarios "/usuarios/:user_order",
               :controller => "users",
               :action => "index",
               :user_order => nil,
               :requirements => {
                 :user_order => ordem_de_usuario
                }

  #==============================================#
  #   URLS dos Tópicos (atenção: N Tópicos)
  #==============================================#
  # Com todos os parametros
  map.connect "/:topico_type/estado/:estado_abrev/cidade/:cidade_slug/bairro/:bairro_id/tags/:tag_id/de/:user_type/:order/:rss",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :rss => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :estado_abrev => estado,
                :cidade_slug => cidade,
                :bairro_id =>  apenas_numeros,
                :tag_id => apenas_numeros,
                :user_type => tipos_de_usuario,
                :order => ordem_de_topico,
                :rss => tipos_de_rss
              }
  # No bairro, com tema: SEM user_type ...
  map.connect "/:topico_type/estado/:estado_abrev/cidade/:cidade_slug/bairro/:bairro_id/tags/:tag_id/:order/:rss",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :rss => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :estado_abrev => estado,
                :cidade_slug => cidade,
                :bairro_id =>  apenas_numeros,
                :tag_id => apenas_numeros,
                :order => ordem_de_topico,
                :rss => tipos_de_rss
              }
  # No bairro, por usuario/criador: SEM tag_id (mas COM user_type) ...
  map.connect "/:topico_type/estado/:estado_abrev/cidade/:cidade_slug/bairro/:bairro_id/de/:user_type/:order",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :estado_abrev => estado,
                :cidade_slug => cidade,
                :bairro_id =>  apenas_numeros,
                :user_type => tipos_de_usuario,
                :order => ordem_de_topico
              }
  # No bairro apenas: SEM user_type e SEM tag_id ...
  map.connect "/:topico_type/estado/:estado_abrev/cidade/:cidade_slug/bairro/:bairro_id/:order",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :estado_abrev => estado,
                :cidade_slug => cidade,
                :bairro_id =>  apenas_numeros,
                :order => ordem_de_topico
              }
  # Na cidade, por tema e usuario/criador: SEM bairro_id (mas COM tag_id e COM user_type) ...
  map.connect "/:topico_type/estado/:estado_abrev/cidade/:cidade_slug/tags/:tag_id/de/:user_type/:order/:rss",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :rss => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :estado_abrev => estado,
                :cidade_slug => cidade,
                :tag_id => apenas_numeros,
                :user_type => tipos_de_usuario,
                :order => ordem_de_topico,
                :rss => tipos_de_rss
              }
  # Na cidade, por usuario/criador: SEM bairro_id e SEM tag_id (mas COM user_type) ...
  map.connect "/:topico_type/estado/:estado_abrev/cidade/:cidade_slug/de/:user_type/:order",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :estado_abrev => estado,
                :cidade_slug => cidade,
                :user_type => tipos_de_usuario,
                :order => ordem_de_topico
              }
  # Na cidade, por tema: SEM bairro_id e SEM user_type (mas COM tag_id) ...
  map.connect "/:topico_type/estado/:estado_abrev/cidade/:cidade_slug/tags/:tag_id/:order/:rss",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :rss => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :estado_abrev => estado,
                :cidade_slug => cidade,
                :tag_id => apenas_numeros,
                :order => ordem_de_topico,
                :rss => tipos_de_rss
              }
  # Na cidade apenas: SEM user_type, SEM tag_id, SEM bairro_id ...
  map.connect "/:topico_type/estado/:estado_abrev/cidade/:cidade_slug/:order",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :estado_abrev => estado,
                :cidade_slug => cidade,
                :order => ordem_de_topico
              }
  # No estado, por usuario/criador: SEM tag_id, SEM bairro_id, SEM cidade_id (mas COM user_type) ...
  map.connect "/:topico_type/estado/:estado_abrev/de/:user_type/:order",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :estado_abrev => estado,
                :user_type => tipos_de_usuario,
                :order => ordem_de_topico
              }
  # No estado, por tema: SEM user_type, SEM bairro_id, SEM cidade_id (mas COM tag_id) ...
  map.connect "/:topico_type/estado/:estado_abrev/tags/:tag_id/:order/:rss",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :rss => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :estado_abrev => estado,
                :tag_id => apenas_numeros,
                :order => ordem_de_topico,
                :rss => tipos_de_rss
              }
  # No estado, por tema e usuario/criador: SEM bairro_id, SEM cidade_id (mas COM tag_id e COM user_type) ...
  map.connect "/:topico_type/estado/:estado_abrev/tags/:tag_id/de/:user_type/:order/:rss",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :rss => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :estado_abrev => estado,
                :tag_id => apenas_numeros,
                :user_type => tipos_de_usuario,
                :order => ordem_de_topico,
                :rss => tipos_de_rss
              }
  # No estado apenas: SEM user_type, SEM tag_id, SEM bairro_id, SEM cidade_slug ...
  map.connect "/:topico_type/estado/:estado_abrev/:order",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :estado_abrev => estado,
                :order => ordem_de_topico
              }
  # Em todo o país, por tema e usuario/criado: COM user_type e COM tag_id ...
  map.connect "/:topico_type/tags/:tag_id/de/:user_type/:order/:rss",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :rss => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :tag_id => apenas_numeros,
                :user_type => tipos_de_usuario,
                :order => ordem_de_topico,
                :rss => tipos_de_rss
              }
  # Em todo o país, por tema: COM tag_id e SEM user_type ...
  map.connect "/:topico_type/de/:user_type/:order",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :user_type => tipos_de_usuario,
                :order => ordem_de_topico
              }
  # Em todo o país, por usuario/criado: SEM user_type e COM tag_id ...
  map.connect "/:topico_type/tags/:tag_id/:order/:rss",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :rss => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :tag_id => apenas_numeros,
                :order => ordem_de_topico,
                :rss => tipos_de_rss
              }
  # Em todo o país...!
  map.topicos "/:topico_type/:order",
              :controller => "topicos",
              :action => "index",
              :order => nil,
              :requirements => {
                :topico_type => tipos_de_topico,
                :order => ordem_de_topico
              }

  #==============================================#
  #   URLS para NOVO Tópico (FORMULÁRIO)
  #==============================================#
  map.novo_topico "/topicos/criar/:topico_type", :controller => "topicos", :action => "new"
  map.localizar_novo_topico "/topicos/criar/:topico_type/localizar", :controller => "topicos", :action => "localizar"

  #==============================================#
  #   URLS do Tópico (atenção: 1 Tópico)
  #==============================================#
  map.topico "/topico/:topico_slug", :controller => "topicos", :action => "show"
  map.editar_topico "/topico/:topico_slug/editar", :controller => "topicos", :action => "edit"
  map.salvar_topico "/topico/:topico_slug/salvar", :controller => "topicos", :action => "update"

  map.aderir "/topico/:topico_slug/aderir", :controller => "topicos", :action => "processar_aderir"
  map.seguir "/topico/:topico_slug/seguir", :controller => "topicos", :action => "processar_seguir"

  # Localização de tópico
  map.topico_localizacao "/topico/:topico_slug/localizacao", :controller => "topicos", :action => "localizacao"

  # Editar Tags de tópico
  map.topico_localizacao "/topico/:topico_slug/tags", :controller => "topicos", :action => "tags"
  map.topico_localizacao "/topico/:topico_slug/tags_by_link", :controller => "topicos", :action => "tags_by_link"

  # Imagens de tópico
  map.topico_imagens "/topico/:topico_slug/imagens", :controller => "imagens", :action => "index"
  map.topico_nova_imagem "/topico/:topico_slug/imagens/nova", :controller => "imagens", :action => "create"
  map.topico_editar_imagem "/topico/:topico_slug/imagens/editar/:id", :controller => "imagens", :action => "edit"
  map.topico_remover_imagem "/topico/:topico_slug/imagens/remover/:id", :controller => "imagens", :action => "destroy"

  # Links de tópico
  map.topico_links "/topico/:topico_slug/links", :controller => "links", :action => "index"
  map.topico_novo_link "/topico/:topico_slug/links/novo", :controller => "links", :action => "create"
  map.topico_remover_link "/topico/:topico_slug/links/remover/:id", :controller => "links", :action => "destroy"

  # Divulgar ou denunciar o tópico
  map.topico_divulgar "/topico/:topico_slug/divulgar", :controller => "topicos", :action => "divulgar"
  map.topico_divulgue_para_todos "/topico/:topico_slug/divulgue_para_todos", :controller => "topicos", :action => "divulgue_para_todos"
  map.topico_denunciar "/topico/:topico_slug/denunciar", :controller => "topicos", :action => "denunciar"


  #======================================#
  #  URLs demais...
  #======================================#
  # Bairros da cidade
  map.connect "/:cidade_slug/bairros", :controller => "locais", :action => "bairros"
  map.connect "/locais/estado/:estado_id/cidades", :controller => "locais", :action => "cidades_options_for_select", :requirements => { :estado_id => apenas_numeros }
  map.connect "/locais/cidade/:cidade_id/bairros", :controller => "locais", :action => "bairros_options_for_select", :requirements => { :cidade_id => apenas_numeros }

  map.promocao "/promocao", :controller => "promocao"
  map.parceiros "/parceiros", :controller => "parceiros"

  # Lista todos as cidades e estados
  map.cidades "/cidades", :controller => "locais", :action => "cidades"
  map.temas "/temas", :controller => "home", :action => "temas"

  # Raiz do site...
  map.root :controller => "home", :action => "index"  

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ":controller/:action/:id"
  map.connect ":controller/:action/:id.:format"

end
