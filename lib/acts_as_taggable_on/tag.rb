class Tag < ActiveRecord::Base

  # LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count
    read_attribute(:count).to_i
  end

  def slug
    self.name.remove_acentos
  end

  # Dada uma tag, retornar tags relacionadas,
  # por meio dos tópicos que possuem a mesma tag.
  def self.relacionadas(tag, options = {})
    if tag
      condicoes = []
      condicoes << "1 = 1"
      condicoes << "topicos.type = '#{options[:topico_type].to_s.singularize.camelize}'" if options[:topico_type] and (options[:topico_type]!="topicos")
      condicoes << "users.type = '#{options[:user_type].to_s.singularize.camelize}'" if options[:user_type] and (options[:user_type]!="usuarios")
      condicoes << "locais.pais_id = '#{options[:pais].id}'" if options[:pais]
      condicoes << "locais.estado_id = '#{options[:estado].id}'" if options[:estado]
      condicoes << "locais.cidade_id = '#{options[:cidade].id}'" if options[:cidade]
      condicoes << "locais.bairro_id = '#{options[:bairro].id}'" if options[:bairro]
      condicoes << "topicos.created_at >= '#{options[:ultimos_dias].to_i.days.ago.to_s(:db)}'" if options[:ultimos_dias]

      plus_localizacao = (condicoes.size > 1) ? " AND taggable_id IN (
SELECT topicos.id
FROM topicos 
   JOIN locais
   JOIN users
   ON (topicos.id = locais.responsavel_id) AND
      (locais.responsavel_type = 'Topico') AND
      (topicos.user_id = users.id)
WHERE #{condicoes.join(' AND ')}
    )" : " "

      sql_string = <<MYSTRING.gsub(/\s+/, " ").strip
      SELECT z.id, z.name, y.total
      FROM tags z INNER JOIN (
        SELECT t.tag_id, count(t.tag_id) AS total
        FROM (
          SELECT p.*
          FROM taggings p WHERE taggable_id IN (
            SELECT taggable_id
            FROM taggings WHERE taggable_type = 'Topico'
                          AND context = 'tags'
                          AND tag_id = #{tag.id}
                              #{plus_localizacao}
          )
        ) t GROUP BY t.tag_id
      ) y ON z.id = y.tag_id
      WHERE z.id <> #{tag.id}
      AND z.name NOT IN (#{self.default_tags})
      ORDER BY y.total DESC
MYSTRING
      return Tag.find_by_sql(sql_string)
    else
      return []
    end    
  end

  # Dado um contexto (pais, estado, cidade, bairro etc.),
  # retornar as TAGS (e os counts) dessas variaveis.
  def self.do_contexto(options = {})
    # Strings a parte...
    condicoes = []
    condicoes << "1 = 1"
    condicoes << "topicos.type = '#{options[:topico_type].to_s.singularize.camelize}'" if options[:topico_type] and (options[:topico_type]!="topicos")
    condicoes << "users.type = '#{options[:user_type].to_s.singularize.camelize}'" if options[:user_type] and (options[:user_type]!="usuarios")
    condicoes << "locais.pais_id = '#{options[:pais].id}'" if options[:pais]
    condicoes << "locais.estado_id = '#{options[:estado].id}'" if options[:estado]
    condicoes << "locais.cidade_id = '#{options[:cidade].id}'" if options[:cidade]
    condicoes << "locais.bairro_id = '#{options[:bairro].id}'" if options[:bairro]
    condicoes << "topicos.created_at >= '#{options[:ultimos_dias].to_i.days.ago.to_s(:db)}'" if options[:ultimos_dias]
    condicoes << "topicos.site = '#{options[:site]}'" if options[:site]
    
    #sql_string_tag   = options[:tag] ? " AND tag_id = #{options[:tag].id} " : ""
    sql_string_tag   = ""
    sql_string_order = options[:order].nil?  ? "z.total DESC" : options[:order]
    sql_string_limit = options[:limit].nil?  ? "" : " LIMIT #{options[:limit]}"

    sql_string = <<MYSTRING.gsub(/\s+/, " ").strip
    SELECT tags.*, z.total
    FROM tags JOIN (
      SELECT b.tag_id, count(b.tag_id) AS total
      FROM (
        SELECT DISTINCT topicos.id
        FROM topicos
          JOIN users
          JOIN locais
             ON (topicos.user_id = users.id)
             AND (locais.responsavel_id = topicos.id)
             AND (locais.responsavel_type = 'Topico')
        WHERE #{condicoes.join(" AND ")}
      ) a JOIN (
      SELECT p.*
      FROM taggings p
        WHERE taggable_id IN (
          SELECT taggable_id
          FROM taggings
          WHERE taggable_type = 'Topico'
            AND context = 'tags'
            #{sql_string_tag}
        )
      ) b
      ON (a.id = b.taggable_id)
      GROUP BY b.tag_id
    ) z
    ON (z.tag_id = tags.id)
    AND tags.name NOT IN (#{self.default_tags})
    ORDER BY #{sql_string_order}
    #{sql_string_limit}
MYSTRING
    return Tag.find_by_sql(sql_string)
  end

  # Retorna as tags mais comuns do usuário.
  def self.do_usuario(user_id, options = {})
    condicoes = []
    condicoes << "topicos.user_id = #{user_id}"
    condicoes << "topicos.type = '#{options[:topico_type].to_s.singularize.camelize}'" if options[:topico_type] and (options[:topico_type]!="topicos")
    condicoes << "topicos.created_at >= '#{options[:ultimos_dias].to_i.days.ago.to_s(:db)}'" if options[:ultimos_dias]

    sql_string_order = options[:order].nil?        ? "z.total DESC" : options[:order]
    sql_string_limit = options[:limit].nil?        ? "" : " LIMIT #{options[:limit]}"

    sql_string = <<MYSTRING.gsub(/\s+/, " ").strip
    SELECT tags.id, tags.name, z.total
    FROM tags JOIN (
      SELECT b.tag_id, count(b.tag_id) AS total
      FROM (
        SELECT topicos.id
        FROM topicos
        WHERE
          #{condicoes.join(' AND ')}
      ) a JOIN (
      SELECT p.*
      FROM taggings p
        WHERE taggable_id IN (
          SELECT taggable_id
          FROM taggings
          WHERE taggable_type = 'Topico'
            AND context = 'tags'
        )
      ) b
      ON (a.id = b.taggable_id)
      GROUP BY b.tag_id
    ) z
    ON (z.tag_id = tags.id)
    ORDER BY #{sql_string_order}
    #{sql_string_limit}
MYSTRING
    return Tag.find_by_sql(sql_string)
  end

  def self.universidades_usp
    [:EACH, :ECA, :EEFE, :EE, :Poli, :FAU,
     :FCF, :FD, :FEA, :FE, :FFLCH, :FM, :FMVZ,
     :FO, :FSP, :IAG, :IB, :ICB, :IEE, :IEA,
     :IEB, :IF, :IGc, :IME, :IMT, :IP, :IQ, :IRI,
     :IO]
  end

  def self.todas_universidades_usp
    conditions = ""
    self.universidades_usp.each_with_index do |universidade, i|
      conditions += "name = '#{universidade}'"
      conditions += " OR " unless i == 28
    end
    Tag.all(:conditions => conditions)
  end

  def self.default_tags
    universidades = ""

    default_tags = ['uspocupa'] + self.universidades_usp
    
    default_tags.each_with_index do |u, i|
      universidades += "'#{u}'"
      universidades += ',' unless i == default_tags.count - 1
    end

    universidades
  end

end
