import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error('DATABASE_URL is not defined in the environment variables.');
}

const adapter = new PrismaPg({
  connectionString,
});

const prisma = new PrismaClient({
  adapter,
});

const roles = [
  {
    code: 'SUPER_ADMIN',
    name: 'Super Administrateur',
    description: 'Accès complet à toutes les fonctionnalités de la plateforme MDP.',
    level: 100,
    isSystem: true,
  },
  {
    code: 'ADMIN',
    name: 'Administrateur',
    description: 'Administration générale de la plateforme MDP.',
    level: 90,
    isSystem: true,
  },
  {
    code: 'COMITE',
    name: 'Comité de Gestion',
    description: 'Membre du comité de gestion de MDP.',
    level: 80,
    isSystem: true,
  },
  {
    code: 'INSPECTEUR',
    name: 'Inspecteur',
    description: 'Responsable de la supervision des superviseurs.',
    level: 70,
    isSystem: true,
  },
  {
    code: 'SUPERVISEUR',
    name: 'Superviseur',
    description: 'Responsable de la supervision des Team Leaders.',
    level: 60,
    isSystem: true,
  },
  {
    code: 'TEAM_LEADER',
    name: 'Team Leader',
    description: 'Responsable de la gestion d’une équipe ou d’un groupe.',
    level: 50,
    isSystem: true,
  },
  {
    code: 'MEMBRE',
    name: 'Membre',
    description: 'Membre de l’organisation MDP.',
    level: 10,
    isSystem: true,
  },
] as const;

const permissions = [
  ['users.create', 'Créer des utilisateurs', 'Permet de créer de nouveaux utilisateurs.'],
  ['users.read', 'Consulter les utilisateurs', 'Permet de consulter les utilisateurs.'],
  ['users.update', 'Modifier les utilisateurs', 'Permet de modifier les utilisateurs.'],
  ['users.delete', 'Supprimer les utilisateurs', 'Permet de supprimer les utilisateurs.'],
  ['users.suspend', 'Suspendre les utilisateurs', 'Permet de suspendre des utilisateurs.'],

  ['roles.create', 'Créer des rôles', 'Permet de créer des rôles.'],
  ['roles.read', 'Consulter les rôles', 'Permet de consulter les rôles.'],
  ['roles.update', 'Modifier les rôles', 'Permet de modifier les rôles.'],
  ['roles.delete', 'Supprimer les rôles', 'Permet de supprimer des rôles.'],
  ['permissions.manage', 'Gérer les permissions', 'Permet de gérer les permissions.'],

  ['organization.create', 'Créer une unité organisationnelle', 'Permet de créer une unité organisationnelle.'],
  ['organization.read', 'Consulter l’organisation', 'Permet de consulter les unités organisationnelles.'],
  ['organization.update', 'Modifier l’organisation', 'Permet de modifier les unités organisationnelles.'],
  ['organization.delete', 'Supprimer une unité organisationnelle', 'Permet de supprimer une unité organisationnelle.'],

  ['members.create', 'Créer des membres', 'Permet de créer des membres.'],
  ['members.read', 'Consulter les membres', 'Permet de consulter les membres.'],
  ['members.update', 'Modifier les membres', 'Permet de modifier les membres.'],
  ['members.delete', 'Supprimer les membres', 'Permet de supprimer des membres.'],
  ['members.suspend', 'Suspendre les membres', 'Permet de suspendre des membres.'],

  ['activities.create', 'Créer des activités', 'Permet de créer des activités.'],
  ['activities.read', 'Consulter les activités', 'Permet de consulter les activités.'],
  ['activities.update', 'Modifier les activités', 'Permet de modifier les activités.'],
  ['activities.delete', 'Supprimer les activités', 'Permet de supprimer des activités.'],

  ['reports.create', 'Créer des rapports', 'Permet de créer des rapports.'],
  ['reports.read', 'Consulter les rapports', 'Permet de consulter les rapports.'],
  ['reports.update', 'Modifier les rapports', 'Permet de modifier les rapports.'],
  ['reports.delete', 'Supprimer les rapports', 'Permet de supprimer des rapports.'],
  ['reports.validate', 'Valider les rapports', 'Permet de valider les rapports.'],
  ['reports.reject', 'Rejeter les rapports', 'Permet de rejeter les rapports.'],

  ['contributions.create', 'Créer des contributions', 'Permet d’enregistrer des contributions.'],
  ['contributions.read', 'Consulter les contributions', 'Permet de consulter les contributions.'],
  ['contributions.update', 'Modifier les contributions', 'Permet de modifier les contributions.'],
  ['contributions.delete', 'Supprimer les contributions', 'Permet de supprimer des contributions.'],

  ['projects.create', 'Créer des projets', 'Permet de créer des projets.'],
  ['projects.read', 'Consulter les projets', 'Permet de consulter les projets.'],
  ['projects.update', 'Modifier les projets', 'Permet de modifier les projets.'],
  ['projects.delete', 'Supprimer les projets', 'Permet de supprimer des projets.'],

  ['sponsors.create', 'Créer des sponsors', 'Permet de créer des sponsors.'],
  ['sponsors.read', 'Consulter les sponsors', 'Permet de consulter les sponsors.'],
  ['sponsors.update', 'Modifier les sponsors', 'Permet de modifier les sponsors.'],
  ['sponsors.delete', 'Supprimer les sponsors', 'Permet de supprimer des sponsors.'],

  ['dashboard.read', 'Consulter le tableau de bord', 'Permet de consulter le tableau de bord.'],

  ['notifications.read', 'Consulter les notifications', 'Permet de consulter les notifications.'],
  ['notifications.manage', 'Gérer les notifications', 'Permet de gérer les notifications.'],

  ['audit.read', 'Consulter les journaux d’audit', 'Permet de consulter les journaux d’audit.'],
] as const;

const businessRules = [
  {
    code: 'MEMBERSHIP_MIN_MONTHLY_CONTRIBUTION',
    name: 'Cotisation mensuelle minimale',
    description: 'Montant minimum de cotisation mensuelle par membre.',
    value: { amount: 10, currency: 'USD' },
  },
  {
    code: 'CONTRIBUTION_CLOSING_DAY',
    name: 'Jour de clôture des cotisations',
    description: 'Le 7 marque la fin de la période précédente et le début de la nouvelle période.',
    value: { day: 7 },
  },
  {
    code: 'FINANCIAL_REPORT_PUBLICATION_DAY',
    name: 'Publication du rapport financier mensuel',
    description: 'Publication mensuelle du rapport détaillé des revenus et dépenses.',
    value: { day: 25 },
  },
  {
    code: 'PROJECT_FLAGSHIP',
    name: 'Projet flagship',
    description: 'Projet proposé par une association bénéficiaire et pouvant démarrer indépendamment du nombre de membres.',
    value: {
      requiresMinimumMembers: false,
      rotates: true,
      proposedBy: 'BENEFICIARY_ASSOCIATION',
    },
  },
  {
    code: 'PROJECT_SECONDARY',
    name: 'Projet secondaire',
    description: 'Projet destiné notamment à une petite église avec seuil de membres.',
    value: {
      minimumMembers: 1000,
      requiresMinimumMembers: true,
    },
  },
  {
    code: 'PROJECT_TERTIARY',
    name: 'Projet tertiaire',
    description: 'Projet de soutien à un projet existant.',
    value: {
      supportAmount: 2500,
      currency: 'USD',
      minimumActiveMdpMembersAtBeneficiaryChurch: 10,
    },
  },
  {
    code: 'MEMBER_PAYMENT_STATUS',
    name: 'Calcul de situation de cotisation',
    description: 'La situation d’un membre est calculée à partir du montant attendu et du montant validé.',
    value: {
      formula: 'balance = expectedAmount - validatedAmount',
      behindWhen: 'balance > 0',
      upToDateWhen: 'balance = 0',
      aheadWhen: 'balance < 0',
    },
  },
] as const;

const paymentDestinations = [
  {
    label: 'Compte Mobile Money MDP 1',
    accountNumber: '+243976068647',
  },
  {
    label: 'Compte Mobile Money MDP 2',
    accountNumber: '+243863160100',
  },
  {
    label: 'Compte Mobile Money MDP 3',
    accountNumber: '+243857245555',
  },
] as const;

async function seedRolesAndPermissions(): Promise<void> {
  console.log('📌 Création / mise à jour des rôles...');

  for (const role of roles) {
    await prisma.role.upsert({
      where: { code: role.code },
      update: {
        name: role.name,
        description: role.description,
        level: role.level,
        isSystem: role.isSystem,
      },
      create: role,
    });
  }

  console.log(`✅ ${roles.length} rôles traités.`);

  console.log('🔐 Création / mise à jour des permissions...');

  for (const [code, name, description] of permissions) {
    await prisma.permission.upsert({
      where: { code },
      update: { name, description },
      create: { code, name, description },
    });
  }

  console.log(`✅ ${permissions.length} permissions traitées.`);

  const superAdminRole = await prisma.role.findUniqueOrThrow({
    where: { code: 'SUPER_ADMIN' },
  });

  const allPermissions = await prisma.permission.findMany({
    select: { id: true },
  });

  for (const permission of allPermissions) {
    await prisma.rolePermission.upsert({
      where: {
        roleId_permissionId: {
          roleId: superAdminRole.id,
          permissionId: permission.id,
        },
      },
      update: {},
      create: {
        roleId: superAdminRole.id,
        permissionId: permission.id,
      },
    });
  }

  console.log(`✅ ${allPermissions.length} permissions affectées à SUPER_ADMIN.`);
}

async function seedOrganizationAndAdmin(): Promise<{
  globalOrganizationId: string;
  superAdminId: string;
}> {
  console.log('🌍 Initialisation de l’organisation MDP...');

  const globalOrganization = await prisma.organizationalUnit.upsert({
    where: {
      id: '00000000-0000-0000-0000-000000000001',
    },
    update: {
      name: 'Maison du Père',
      description: 'Organisation mondiale Maison du Père (MDP).',
      type: 'GLOBAL',
      isActive: true,
    },
    create: {
      id: '00000000-0000-0000-0000-000000000001',
      name: 'Maison du Père',
      description: 'Organisation mondiale Maison du Père (MDP).',
      type: 'GLOBAL',
      isActive: true,
    },
  });

  const email = (
    process.env.SUPER_ADMIN_EMAIL ?? 'admin@mdp2027.com'
  ).trim().toLowerCase();

  const password = process.env.SUPER_ADMIN_PASSWORD ?? 'ChangeMe123!';
  const passwordHash = await bcrypt.hash(password, 12);

  console.log('👑 Initialisation du compte SUPER_ADMIN...');

  const superAdmin = await prisma.user.upsert({
    where: { email },
    update: {
      loginId: 'MDP-ADMIN-001',
      firstName: 'Super',
      lastName: 'Admin',
      passwordHash,
      phone: null,
      status: 'ACTIVE',
      accountType: 'SYSTEM',
      memberId: null,
      organizationalUnitId: globalOrganization.id,
    },
    create: {
      loginId: 'MDP-ADMIN-001',
      email,
      passwordHash,
      firstName: 'Super',
      lastName: 'Admin',
      status: 'ACTIVE',
      accountType: 'SYSTEM',
      organizationalUnitId: globalOrganization.id,
    },
  });

  await prisma.userRole.upsert({
    where: {
      userId_roleId: {
        userId: superAdmin.id,
        roleId: (
          await prisma.role.findUniqueOrThrow({
            where: { code: 'SUPER_ADMIN' },
            select: { id: true },
          })
        ).id,
      },
    },
    update: {},
    create: {
      userId: superAdmin.id,
      roleId: (
        await prisma.role.findUniqueOrThrow({
          where: { code: 'SUPER_ADMIN' },
          select: { id: true },
        })
      ).id,
    },
  });

  await prisma.organizationalUnit.update({
    where: { id: globalOrganization.id },
    data: { leaderId: superAdmin.id },
  });

  console.log(`✅ SUPER_ADMIN prêt : ${email}`);

  return {
    globalOrganizationId: globalOrganization.id,
    superAdminId: superAdmin.id,
  };
}

async function seedBusinessRules(): Promise<void> {
  console.log('⚙️ Initialisation des règles métier MDP...');

  for (const rule of businessRules) {
    await prisma.businessRule.upsert({
      where: { code: rule.code },
      update: {
        name: rule.name,
        description: rule.description,
        value: rule.value,
        isActive: true,
      },
      create: {
        code: rule.code,
        name: rule.name,
        description: rule.description,
        value: rule.value,
        isActive: true,
        version: 1,
      },
    });
  }

  console.log(`✅ ${businessRules.length} règles métier traitées.`);
}

async function seedPaymentConfiguration(): Promise<void> {
  console.log('💳 Initialisation des moyens de paiement...');

  const mobileMoneyProvider = await prisma.paymentProvider.upsert({
    where: { code: 'MDP_MOBILE_MONEY' },
    update: {
      name: 'Mobile Money MDP',
      type: 'MOBILE_MONEY',
      isActive: true,
      configuration: {
        mode: 'MANUAL_PROOF',
        requiresProof: true,
      },
    },
    create: {
      code: 'MDP_MOBILE_MONEY',
      name: 'Mobile Money MDP',
      type: 'MOBILE_MONEY',
      isActive: true,
      configuration: {
        mode: 'MANUAL_PROOF',
        requiresProof: true,
      },
    },
  });

  for (const destination of paymentDestinations) {
    const existing = await prisma.paymentDestination.findFirst({
      where: {
        providerId: mobileMoneyProvider.id,
        accountNumber: destination.accountNumber,
      },
      select: { id: true },
    });

    const data = {
      label: destination.label,
      accountNumber: destination.accountNumber,
      accountName: 'MDP',
      currency: 'USD',
      isActive: true,
      metadata: {
        purpose: 'MEMBER_CONTRIBUTIONS',
      },
    };

    if (existing) {
      await prisma.paymentDestination.update({
        where: { id: existing.id },
        data,
      });
    } else {
      await prisma.paymentDestination.create({
        data: {
          providerId: mobileMoneyProvider.id,
          ...data,
        },
      });
    }
  }

  await prisma.paymentProvider.upsert({
    where: { code: 'MDP_CARD' },
    update: {
      name: 'Carte bancaire',
      type: 'CARD',
      isActive: false,
      configuration: {
        mode: 'NOT_CONFIGURED',
        readyForProviderIntegration: true,
      },
    },
    create: {
      code: 'MDP_CARD',
      name: 'Carte bancaire',
      type: 'CARD',
      isActive: false,
      configuration: {
        mode: 'NOT_CONFIGURED',
        readyForProviderIntegration: true,
      },
    },
  });

  console.log(`✅ ${paymentDestinations.length} destinations Mobile Money configurées.`);
  console.log('✅ Provider carte bancaire préparé mais désactivé.');
}

async function seedAccountingPeriod(): Promise<void> {
  console.log('📅 Initialisation de la période comptable courante...');

  const year = 2026;
  const month = 9;

  const startsAt = new Date('2026-09-08T00:00:00.000Z');
  const endsAt = new Date('2026-10-07T23:59:59.999Z');

  const period = await prisma.accountingPeriod.upsert({
    where: {
      year_month: { year, month },
    },
    update: {
      code: '2026-09',
      startsAt,
      endsAt,
      status: 'OPEN',
    },
    create: {
      code: '2026-09',
      year,
      month,
      startsAt,
      endsAt,
      status: 'OPEN',
    },
  });

  console.log(`✅ Période comptable ${period.code} prête.`);
}

async function main(): Promise<void> {
  console.log('');
  console.log('==============================================');
  console.log('🌱 MDP 2027 — SEED V2');
  console.log('==============================================');
  console.log('');

  await seedRolesAndPermissions();
  await seedOrganizationAndAdmin();
  await seedBusinessRules();
  await seedPaymentConfiguration();
  await seedAccountingPeriod();

  console.log('');
  console.log('==============================================');
  console.log('🎉 SEED MDP V2 TERMINÉ');
  console.log('==============================================');
  console.log('Admin : admin@mdp2027.com');
  console.log('Login ID : MDP-ADMIN-001');
  console.log('==============================================');
}

main()
  .catch((error) => {
    console.error('❌ Database seed failed:', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
