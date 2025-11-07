-- -------------------------------------------------------------------
-- ----------------------- ATIVIDADE ---------------------------------
-- -------------------------------------------------------------------

-- Preparação:

-- - execute o script "sala-ddl.sql"
-- - após o banco criado, execute o script "sala-dml.sql"

-- Responda as questões abaixo, quando for discursiva, escreva em comentários

-- 1) O que você achou da forma como o banco foi populado (arquivo sala-dml.sql)?
--      Há formas melhores de ter feito esse preenchimento? Como?
--      Como melhorar esse script usando comandos TCL?
--      Obs.: Essa questão é discursiva, não envie códigos nela.

-- Achei que a maneira de dar os inserts foi bem extensa com 24.274 linhas apenas de inserts, por conta da quantidade colocada em cada table, mas creio que usando o 
-- insert de forma multipla, ao inves de dar um insert por linha, colocar mais valores por exemplo dentro de um insert apenas agrupando por cada table;
-- Dando o setcommit = 0 para iniciar, apos o start transaction colocar todos os inserts agrupados por table e realizar o commit, caso nao esteja certo, dar o rollback.

-- 2) É mais comum buscar pessoas por documentos, crie um índice para CPF na tabela de Pessoa. (código de criação do índice)

-- CREATE INDEX idx_pessoa_cpf
-- ON Pessoa (CPF);

-- 3) Em Avaliacao, há um campo TEXT, o campo ocorrencia, que contém ocorrências ocorridas durante as avaliações
-- a)   crie um FULLTEXT INDEX para esse campo, inclua o tipo_prova no índice

-- ALTER TABLE Avaliacao
-- ADD FULLTEXT INDEX ft_avaliacao_ocorrencia_tipo
-- (ocorrencia , stipo_prova)

-- b)   faça uma busca por suspeitas de cola na P3 utilizando apenas o índice



-- 4) Quais os benefícios e cuidados com a criação desses índices?

-- para acelerar a busca por dados em uma tabela. deixando o codigo mais limpo e mais objetivo

-- 5) Crie uma VIEW que gere uma tabela virtual com os estudantes que estão regularmente matriculados e que não estão sob medidas disciplinares formais,
--  mas possuem registros de ocorrências durante avaliações.

-- create vw_aluno_ocorrencias as select
-- a.matricula,
-- p.nome,
-- av.ocorrencia, 
-- av.nota 
-- from Aluno a
-- join Pessoa p ON p.ID = a.pessoa_id
-- join  Aluno_Turma at ON at.aluno_mat = a.matricula
-- join Avaliacao av ON av.aluno_turma_id = at.ID
-- where a.status = 'ativo'
-- and av.ocorrencia IS NOT NULL
-- and a.status NOT IN ('suspenso', 'expulso');

-- 6) Crie duas VIEWs, uma para apresentar os dados do professor (tabelas Professor e Pessoa) e outra para apresentar os dados dos alunos (tabelas Pessoa e Aluno).

-- create view vw_professores as 
-- select
-- pr.matricula as matricula_professor,
--  p.nome as nome_professor,
--  p.cpf as cpf,
--  p.data_nascimento,
--  p.end_logradouro,
--  p.end_numero,
--  p.end_complemento,  
--  p.end_bairro,
--  p.end_cidade,
--  p.end_uf_sigla,
--  pr.ativo
-- FROM Professor pr
-- JOIN Pessoa p ON p.ID = pr.pessoa_id;

-- create view vw_alunos as 
-- select
--  a.matricula AS matricula_aluno,
--  p.nome AS nome_aluno,
--  p.cpf AS cpf,
--  p.data_nascimento,
--  p.end_logradouro,
--  p.end_cidade,
--  p.end_uf_sigla,
--  a.status,
--  a.dt_matricula,
--  p.end_numero,
--  p.end_complemento,
--  p.end_bairro
-- FROM Aluno a
-- JOIN Pessoa p ON p.ID = a.pessoa_id;


-- 7) Crie uma ROLE Secretaria, que terá permissão de acesso a todo o banco, mas não poderá excluir nenhum dado.

-- CREATE USER 'secretaria_user'@'localhost'
-- IDENTIFIED BY 'secretaria';

-- create role Secretaria;
-- GRANT 
-- SELECT, INSERT, UPDATE, CREATE, ALTER, INDEX
-- ON SalaDeAula.*
-- TO Secretaria;
-- GRANT Secretaria TO 'secretaria_user'@'localhost';
-- SET DEFAULT ROLE Secretaria TO 'secretaria_user'@'localhost';

-- 8) Crie um usuário Maria, Maria é secretária acadêmica, atribua os acesso de Secretaria a Maria.

-- CREATE USER 'Maria'@'localhost'
-- IDENTIFIED BY 'maria';
-- GRANT Secretaria TO 'Maria'@'localhost';
-- SET DEFAULT ROLE Secretaria TO 'Maria'@'localhost';

-- 9) Crie uma TRIGGER que zere a nota de uma avaliação caso seja inserida com uma ocorrência que justifique isso.

-- DELIMITER //
-- CREATE TRIGGER trg_zerar_nota_ocorrencia
-- BEFORE INSERT ON Avaliacao
-- FOR EACH ROW
-- BEGIN
-- IF NEW.ocorrencia IS NOT NULL AND (
-- NEW.ocorrencia LIKE '%cola%' 
-- OR NEW.ocorrencia LIKE '%fraude%'
-- OR NEW.ocorrencia LIKE '%plagio%'
-- OR NEW.ocorrencia LIKE '%cola%' COLLATE utf8mb4_general_ci
-- ) THEN
-- SET NEW.nota = 0.0;
-- END IF;
-- END;
-- //
-- DELIMITER ;


-- 10) Crie uma TRIGGER que zere a nota de uma avaliação caso seja atualizada adicionando uma ocorrência que justifique isso.

-- DELIMITER //
-- CREATE TRIGGER trg_zerar_nota_ocorrencia_update
-- BEFORE UPDATE ON Avaliacao
-- FOR EACH ROW
-- BEGIN
--   IF NEW.ocorrencia IS NOT NULL AND (
--        NEW.ocorrencia LIKE '%cola%'
--     OR NEW.ocorrencia LIKE '%fraude%'
--     OR NEW.ocorrencia LIKE '%plagio%'
--     OR NEW.ocorrencia LIKE '%cola%' COLLATE utf8mb4_general_ci
--   ) THEN
--     SET NEW.nota = 0.0;
--   END IF;
-- END;
-- //
-- DELIMITER ;


-- 11) Crie uma (ou mais) FUNCTION que calcule a nota final por disciplina e aluno.

-- DELIMITER //
-- CREATE FUNCTION fn_calcula_nota_final(alunoMatricula VARCHAR, materiaCod INT)
-- RETURNS double(4,2)
-- DETERMINISTIC
-- BEGIN
--   DECLARE notaFinal DOUBLE(4,2);
--
--   SELECT AVG(a.nota)
--   INTO notaFinal
--   FROM Avaliacao a
--   JOIN Aluno_Turma at ON at.ID = a.aluno_turma_id
--   JOIN Turma t ON t.codigo = at.turma_cod
--   JOIN Materia m ON m.curso_cod = t.curso_cod
--   WHERE m.ID = materiaCod
--     AND m.aluno_mat = alunoMatricula;
--
--   RETURN IF NULL(notaFinal, 0.0);
-- END;
-- //
-- DELIMITER ;


-- 12) Crie uma PROCEDURE que, caso o aluno tenha 3 ou mais ocorrências, deverá ser suspenso, caso esteja suspenso e tenha 9 ou mais ocorrências, expulso.
