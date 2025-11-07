drop database if exists SalaDeAula;

create database if not exists SalaDeAula;

use SalaDeAula;

create table if not exists Pessoa(
	ID int primary key auto_increment,
	CPF varchar(11) unique not null,
	nome varchar(255) not null,
	data_nascimento date not null,
	end_logradouro varchar(255) not null,
	end_numero int not null,
	end_complemento varchar(255),
	end_bairro varchar(255) not null,
	end_cidade varchar(255) not null,
	end_uf_sigla char(2) not null
) ENGINE=InnoDB;

create table if not exists Aluno(
	matricula varchar(10) PRIMARY key,
	status ENUM(
        'ativo',
        'inativo',
        'formado',
        'suspenso',
        'expulso',
        'transferido',
        'pendenteDocumentacao',
        'cancelado'
    ) NOT NULL DEFAULT 'ativo',
    dt_matricula date not null default (CURRENT_DATE),
	pessoa_id int not null,
	constraint pessoa_estudante_fk
	FOREIGN KEY(pessoa_id) REFERENCES Pessoa(ID)
	on update cascade
	on delete restrict
) ENGINE=InnoDB;

create table if not exists Professor(
	matricula varchar(8) PRIMARY key,
	ativo boolean NOT NULL DEFAULT TRUE,
	pessoa_id int not null,
	constraint pessoa_professor_fk
	FOREIGN KEY(pessoa_id) REFERENCES Pessoa(ID)
	on update cascade
	on delete restrict
) ENGINE=InnoDB;

create table if not exists Curso(
	codigo varchar(10) primary key,
	nome varchar(255) not null,
	turno enum('integral', 'matutino', 'vespertino', 'noturno') not null default 'integral'
) ENGINE=InnoDB;

create table if not exists Turma(
	codigo varchar(12) primary key,
	ano_semestre varchar(6) not null,
	curso_cod varchar(10) not null,
	professor_mat varchar(8) not null,
	constraint turma_curso_fk
	FOREIGN KEY(curso_cod) REFERENCES Curso(codigo)
	on update cascade
	on delete restrict,
	constraint turma_professor_fk
	FOREIGN KEY(professor_mat) REFERENCES Professor(matricula)
	on update cascade
	on delete restrict	
) ENGINE=InnoDB;

create table if not exists Aluno_Curso(
	id int primary key auto_increment,
	curso_cod varchar(10) not null,
	aluno_mat varchar(10) not null,
	dt_inicio date not null default (current_date),
	dt_fim date,
	constraint curso_ac_fk
	FOREIGN KEY(curso_cod) REFERENCES Curso(codigo)
	on update cascade
	on delete restrict,
	constraint aluno_ac_fk
	FOREIGN KEY(aluno_mat) REFERENCES Aluno(matricula)
	on update cascade
	on delete restrict
) ENGINE=InnoDB;

create table if not exists Materia(
	ID int primary key auto_increment,
	nome varchar(12) not null,
	aluno_mat varchar(10) not null,
	curso_cod varchar(10) not null,
	constraint aluno_materia_fk
	FOREIGN KEY(aluno_mat) REFERENCES Aluno(matricula)
	on update cascade
	on delete restrict,
	constraint curso_materia_fk
	FOREIGN KEY(curso_cod) REFERENCES Curso(codigo)
	on update cascade
	on delete restrict
) ENGINE=InnoDB;

create table if not exists Aluno_Turma(
	ID int primary key auto_increment,
	turma_cod varchar(12) not null,
	aluno_mat varchar(10) not null,
	UNIQUE(turma_cod, aluno_mat),
	constraint turma_at_fk
	FOREIGN KEY(turma_cod) REFERENCES Turma(codigo)
	on update cascade
	on delete restrict,
	constraint aluno_at_fk
	FOREIGN KEY(aluno_mat) REFERENCES Aluno(matricula)
	on update cascade
	on delete restrict
) ENGINE=InnoDB;

create table if not exists Avaliacao(
	ID int primary key auto_increment,
	aluno_turma_id int not null,
	tipo_prova ENUM('P1','P2','P3','P4','P5','Rec') not null default 'P1',
	nota decimal(3,1) not null default 0.0,
	ocorrencia TEXT,
	UNIQUE(aluno_turma_id, tipo_prova),
	constraint aluno_turma_avaliacao_fk
	FOREIGN KEY(aluno_turma_id) REFERENCES Aluno_Turma(ID)
	on update cascade
	on delete restrict
) ENGINE=InnoDB;